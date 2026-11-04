// Emulator tests for ../firestore.rules.
//
// Run from this folder (never contacts the real project):
//   npm install
//   firebase emulators:exec --only firestore --project demo-darts "npm test"

import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  collectionGroup,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  query,
  runTransaction,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

// RULES_FILE lets you point the suite at another rules file (e.g. a mutated copy).
const RULES = readFileSync(
  process.env.RULES_FILE ?? new URL('../firestore.rules', import.meta.url),
  'utf8',
);
const SEED_TIME = Timestamp.fromDate(new Date('2026-01-01T00:00:00Z'));

// Seeded users: alice, bob and carol each have a profile + code; alice and
// bob are friends; alice has one backed-up game. dave is signed in
// (anonymously) but has no profile yet. ghost has nothing at all.
const USERS = [
  ['alice', 'Alice', 'ALCE23'],
  ['bob', 'Bob', 'BBQ234'],
  ['carol', 'Carol', 'CRL234'],
];

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-darts',
    firestore: { rules: RULES },
  });
});

after(async () => {
  await env?.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    for (const [uid, name, code] of USERS) {
      await setDoc(doc(db, 'profiles', uid), {
        name,
        code,
        createdAt: SEED_TIME,
        updatedAt: SEED_TIME,
      });
      await setDoc(doc(db, 'codes', code), { uid });
    }
    await setDoc(doc(db, 'profiles/alice/friends/bob'), { addedAt: SEED_TIME });
    await setDoc(doc(db, 'profiles/bob/friends/alice'), { addedAt: SEED_TIME });
    await setDoc(doc(db, 'profiles/alice/games/g1'), {
      json: '{"rounds":[]}',
      playedAt: SEED_TIME,
    });
  });
});

const as = (uid) =>
  env
    .authenticatedContext(uid, { firebase: { sign_in_provider: 'anonymous' } })
    .firestore();
const anon = () => env.unauthenticatedContext().firestore();

const omit = (obj, key) => {
  const { [key]: _, ...rest } = obj;
  return rest;
};

const newProfile = (over = {}) => ({
  name: 'Dave',
  code: 'DAVE23',
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...over,
});

// Writes profiles/{uid} and codes/{codeId} = codeData in one batch.
function createProfileBatch(db, uid, profile, codeId = profile.code, codeData = { uid }) {
  const b = writeBatch(db);
  b.set(doc(db, 'profiles', uid), profile);
  if (codeId) b.set(doc(db, 'codes', codeId), codeData);
  return b.commit();
}

// Mutual add: me adds them to my list and myself to theirs.
function mutualAdd(db, me, them, mine = { addedAt: serverTimestamp() }, theirs = mine) {
  const b = writeBatch(db);
  b.set(doc(db, 'profiles', me, 'friends', them), mine);
  b.set(doc(db, 'profiles', them, 'friends', me), theirs);
  return b.commit();
}

// ===================================================================
describe('profiles/{uid}', () => {
  describe('get / list', () => {
    it('unauthenticated get -> denied', async () => {
      await assertFails(getDoc(doc(anon(), 'profiles/alice')));
    });
    it('stranger (carol) gets alice by uid -> allowed', async () => {
      await assertSucceeds(getDoc(doc(as('carol'), 'profiles/alice')));
    });
    it('signed-in user without profile (dave) gets alice -> allowed', async () => {
      await assertSucceeds(getDoc(doc(as('dave'), 'profiles/alice')));
    });
    it('stranger lists all profiles -> denied', async () => {
      await assertFails(getDocs(collection(as('carol'), 'profiles')));
    });
    it('stranger queries profiles where code == ALCE23 -> denied', async () => {
      await assertFails(
        getDocs(query(collection(as('carol'), 'profiles'), where('code', '==', 'ALCE23'))),
      );
    });
    it('owner queries profiles where name == Alice -> denied (list is always off)', async () => {
      await assertFails(
        getDocs(query(collection(as('alice'), 'profiles'), where('name', '==', 'Alice'))),
      );
    });
    it('unauthenticated list -> denied', async () => {
      await assertFails(getDocs(collection(anon(), 'profiles')));
    });
  });

  describe('create', () => {
    it('profile + code in one batch -> allowed', async () => {
      await assertSucceeds(createProfileBatch(as('dave'), 'dave', newProfile()));
    });
    it('profile + code in one transaction -> allowed', async () => {
      const db = as('dave');
      await assertSucceeds(
        runTransaction(db, async (tx) => {
          const snap = await tx.get(doc(db, 'codes', 'DAVE23'));
          if (snap.exists()) throw new Error('code taken');
          tx.set(doc(db, 'profiles', 'dave'), newProfile());
          tx.set(doc(db, 'codes', 'DAVE23'), { uid: 'dave' });
        }),
      );
    });
    it('with x01 {value:null,games:3} and cricket {value:2.4,games:12} -> allowed', async () => {
      await assertSucceeds(
        createProfileBatch(
          as('dave'),
          'dave',
          newProfile({ x01: { value: null, games: 3 }, cricket: { value: 2.4, games: 12 } }),
        ),
      );
    });
    it('name of exactly 40 chars -> allowed', async () => {
      await assertSucceeds(
        createProfileBatch(as('dave'), 'dave', newProfile({ name: 'x'.repeat(40) })),
      );
    });
    it('rating at bounds (x01 180, cricket 0) -> allowed', async () => {
      await assertSucceeds(
        createProfileBatch(
          as('dave'),
          'dave',
          newProfile({ x01: { value: 180, games: 0 }, cricket: { value: 0, games: 0 } }),
        ),
      );
    });
    it('unauthenticated -> denied', async () => {
      await assertFails(createProfileBatch(anon(), 'dave', newProfile()));
    });
    it('profile without the codes doc -> denied', async () => {
      await assertFails(setDoc(doc(as('dave'), 'profiles/dave'), newProfile()));
    });
    it("profile at someone else's uid (dave writes profiles/ghost) -> denied", async () => {
      await assertFails(
        createProfileBatch(as('dave'), 'ghost', newProfile(), 'DAVE23', { uid: 'ghost' }),
      );
    });
    it('codes doc in the batch points at another uid -> denied', async () => {
      await assertFails(
        createProfileBatch(as('dave'), 'dave', newProfile(), 'DAVE23', { uid: 'ghost' }),
      );
    });
    it("claims alice's existing code (profile only) -> denied", async () => {
      await assertFails(
        setDoc(doc(as('dave'), 'profiles/dave'), newProfile({ code: 'ALCE23' })),
      );
    });
    it("claims alice's existing code (profile + overwrite codes doc) -> denied", async () => {
      await assertFails(createProfileBatch(as('dave'), 'dave', newProfile({ code: 'ALCE23' })));
    });
    it('profile code differs from the codes doc written -> denied', async () => {
      await assertFails(
        createProfileBatch(as('dave'), 'dave', newProfile({ code: 'DAVE23' }), 'DAVE34'),
      );
    });

    for (const [label, name] of [
      ['empty name', ''],
      ['41-char name', 'x'.repeat(41)],
      ['numeric name', 123],
      ['null name', null],
    ]) {
      it(`${label} -> denied`, async () => {
        await assertFails(createProfileBatch(as('dave'), 'dave', newProfile({ name })));
      });
    }

    for (const [label, code] of [
      ['5-char code', 'DAVE2'],
      ['7-char code', 'DAVE234'],
      ['code with O', 'DAVEO2'],
      ['code with I', 'DAVEI2'],
      ['code with 1', 'DAVE12'],
      ['code with 0', 'DAVE02'],
      ['lowercase code', 'dave23'],
    ]) {
      it(`${label} (${code}) -> denied`, async () => {
        await assertFails(createProfileBatch(as('dave'), 'dave', newProfile({ code })));
      });
    }

    it('createdAt set to a client timestamp -> denied', async () => {
      await assertFails(
        createProfileBatch(as('dave'), 'dave', newProfile({ createdAt: SEED_TIME })),
      );
    });
    it('updatedAt set to a client timestamp -> denied', async () => {
      await assertFails(
        createProfileBatch(as('dave'), 'dave', newProfile({ updatedAt: Timestamp.now() })),
      );
    });
    it('createdAt as a string -> denied', async () => {
      await assertFails(
        createProfileBatch(as('dave'), 'dave', newProfile({ createdAt: '2026-01-01' })),
      );
    });
    it('extra key (email) -> denied', async () => {
      await assertFails(
        createProfileBatch(as('dave'), 'dave', newProfile({ email: 'd@example.com' })),
      );
    });
    for (const key of ['name', 'code', 'createdAt', 'updatedAt']) {
      it(`missing ${key} -> denied`, async () => {
        const p = omit(newProfile(), key);
        await assertFails(
          createProfileBatch(as('dave'), 'dave', p, 'DAVE23', { uid: 'dave' }),
        );
      });
    }

    for (const [label, over] of [
      ['x01.value is a string', { x01: { value: '50', games: 5 } }],
      ['x01.value negative', { x01: { value: -1, games: 5 } }],
      ['x01.value above 180', { x01: { value: 180.5, games: 5 } }],
      ['x01.value NaN', { x01: { value: NaN, games: 5 } }],
      ['cricket.value above 9', { cricket: { value: 9.5, games: 5 } }],
      ['x01.games negative', { x01: { value: 50, games: -1 } }],
      ['x01.games fractional', { x01: { value: 50, games: 1.5 } }],
      ['x01.games missing', { x01: { value: 50 } }],
      ['x01.value missing', { x01: { games: 5 } }],
      ['x01 has an extra key', { x01: { value: 50, games: 5, best: 99 } }],
      ['x01 is a number', { x01: 50 }],
      ['cricket is null', { cricket: null }],
    ]) {
      it(`${label} -> denied`, async () => {
        await assertFails(createProfileBatch(as('dave'), 'dave', newProfile(over)));
      });
    }
  });

  describe('update', () => {
    it('owner renames with updatedAt = serverTimestamp -> allowed', async () => {
      await assertSucceeds(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          name: 'Alicia',
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('owner writes ratings -> allowed', async () => {
      await assertSucceeds(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          x01: { value: 48.7, games: 20 },
          cricket: { value: null, games: 2 },
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('owner removes an optional rating -> allowed', async () => {
      const db = as('alice');
      await assertSucceeds(
        updateDoc(doc(db, 'profiles/alice'), {
          x01: { value: 40, games: 6 },
          updatedAt: serverTimestamp(),
        }),
      );
      await assertSucceeds(
        updateDoc(doc(db, 'profiles/alice'), { x01: deleteField(), updatedAt: serverTimestamp() }),
      );
    });
    it('owner changes code -> denied', async () => {
      await assertFails(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          code: 'ALCE34',
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('owner changes code and claims the new codes doc in one batch -> denied', async () => {
      const db = as('alice');
      const b = writeBatch(db);
      b.update(doc(db, 'profiles/alice'), { code: 'ALCE34', updatedAt: serverTimestamp() });
      b.set(doc(db, 'codes/ALCE34'), { uid: 'alice' });
      await assertFails(b.commit());
    });
    it('owner changes createdAt -> denied', async () => {
      await assertFails(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          createdAt: serverTimestamp(),
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('owner deletes createdAt -> denied', async () => {
      await assertFails(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          createdAt: deleteField(),
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('owner leaves updatedAt stale -> denied', async () => {
      await assertFails(updateDoc(doc(as('alice'), 'profiles/alice'), { name: 'Alicia' }));
    });
    it('owner sets updatedAt to a client timestamp -> denied', async () => {
      await assertFails(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          name: 'Alicia',
          updatedAt: Timestamp.now(),
        }),
      );
    });
    it('owner adds an extra key -> denied', async () => {
      await assertFails(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          isAdmin: true,
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('owner sets a 41-char name -> denied', async () => {
      await assertFails(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          name: 'x'.repeat(41),
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('owner sets a 1 MB name -> denied', async () => {
      await assertFails(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          name: 'x'.repeat(1_000_000),
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('owner removes name -> denied', async () => {
      await assertFails(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          name: deleteField(),
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('owner writes an invalid rating (games -1) -> denied', async () => {
      await assertFails(
        updateDoc(doc(as('alice'), 'profiles/alice'), {
          x01: { value: 50, games: -1 },
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it("stranger (carol) updates alice's profile -> denied", async () => {
      await assertFails(
        updateDoc(doc(as('carol'), 'profiles/alice'), {
          name: 'hacked',
          updatedAt: serverTimestamp(),
        }),
      );
    });
    it('unauthenticated update -> denied', async () => {
      await assertFails(
        updateDoc(doc(anon(), 'profiles/alice'), { name: 'hacked', updatedAt: serverTimestamp() }),
      );
    });
  });

  describe('delete', () => {
    it('owner deletes own profile -> allowed', async () => {
      await assertSucceeds(deleteDoc(doc(as('alice'), 'profiles/alice')));
    });
    it("stranger deletes alice's profile -> denied", async () => {
      await assertFails(deleteDoc(doc(as('carol'), 'profiles/alice')));
    });
    it('unauthenticated delete -> denied', async () => {
      await assertFails(deleteDoc(doc(anon(), 'profiles/alice')));
    });
  });
});

// ===================================================================
describe('codes/{code}', () => {
  it('signed-in get of a scanned code -> allowed', async () => {
    await assertSucceeds(getDoc(doc(as('carol'), 'codes/ALCE23')));
  });
  it('signed-in get of an unused code -> allowed (returns not found)', async () => {
    await assertSucceeds(getDoc(doc(as('dave'), 'codes/ZZZZ99')));
  });
  it('unauthenticated get -> denied', async () => {
    await assertFails(getDoc(doc(anon(), 'codes/ALCE23')));
  });
  it('signed-in list of all codes -> denied', async () => {
    await assertFails(getDocs(collection(as('carol'), 'codes')));
  });
  it('signed-in query codes where uid == alice -> denied', async () => {
    await assertFails(
      getDocs(query(collection(as('carol'), 'codes'), where('uid', '==', 'alice'))),
    );
  });
  it('create alone with no profile -> denied', async () => {
    await assertFails(setDoc(doc(as('dave'), 'codes/DAVE23'), { uid: 'dave' }));
  });
  it('create with uid of another user (in a profile batch) -> denied', async () => {
    await assertFails(
      createProfileBatch(as('dave'), 'dave', newProfile(), 'DAVE23', { uid: 'alice' }),
    );
  });
  it('create with an extra key -> denied', async () => {
    await assertFails(
      createProfileBatch(as('dave'), 'dave', newProfile(), 'DAVE23', {
        uid: 'dave',
        name: 'Dave',
      }),
    );
  });
  it('create without uid -> denied', async () => {
    await assertFails(createProfileBatch(as('dave'), 'dave', newProfile(), 'DAVE23', {}));
  });
  it("create a second code that isn't the owner's profile code -> denied", async () => {
    await assertFails(setDoc(doc(as('alice'), 'codes/ALCE34'), { uid: 'alice' }));
  });
  it('unauthenticated create -> denied', async () => {
    await assertFails(setDoc(doc(anon(), 'codes/DAVE23'), { uid: 'dave' }));
  });
  it('re-create own code after deleting it, profile unchanged -> allowed', async () => {
    const db = as('alice');
    await assertSucceeds(deleteDoc(doc(db, 'codes/ALCE23')));
    await assertSucceeds(setDoc(doc(db, 'codes/ALCE23'), { uid: 'alice' }));
  });
  it('owner rewrites own codes doc (same data) -> denied (no updates)', async () => {
    await assertFails(setDoc(doc(as('alice'), 'codes/ALCE23'), { uid: 'alice' }));
  });
  it('owner reassigns own code to bob -> denied', async () => {
    await assertFails(setDoc(doc(as('alice'), 'codes/ALCE23'), { uid: 'bob' }));
  });
  it("bob overwrites alice's code with his uid -> denied", async () => {
    await assertFails(setDoc(doc(as('bob'), 'codes/ALCE23'), { uid: 'bob' }));
  });
  it('owner deletes own code -> allowed', async () => {
    await assertSucceeds(deleteDoc(doc(as('alice'), 'codes/ALCE23')));
  });
  it("stranger deletes alice's code -> denied", async () => {
    await assertFails(deleteDoc(doc(as('carol'), 'codes/ALCE23')));
  });
  it('unauthenticated delete -> denied', async () => {
    await assertFails(deleteDoc(doc(anon(), 'codes/ALCE23')));
  });
  it('delete of a code that does not exist -> denied', async () => {
    await assertFails(deleteDoc(doc(as('dave'), 'codes/ZZZZ99')));
  });
  it('owner deletes profile, then re-creates it with a new code -> allowed (old code doc stays)', async () => {
    const db = as('alice');
    await assertSucceeds(deleteDoc(doc(db, 'profiles/alice')));
    await assertSucceeds(
      createProfileBatch(db, 'alice', newProfile({ name: 'Alice', code: 'ALCE34' })),
    );
    await assertSucceeds(getDoc(doc(db, 'codes/ALCE23')));
  });
  it('KNOWN GAP: after alice deletes only her code doc, dave can claim ALCE23 -> allowed', async () => {
    await assertSucceeds(deleteDoc(doc(as('alice'), 'codes/ALCE23')));
    await assertSucceeds(
      createProfileBatch(as('dave'), 'dave', newProfile({ code: 'ALCE23' })),
    );
  });
});

// ===================================================================
describe('profiles/{uid}/friends/{friendUid}', () => {
  describe('read', () => {
    it('owner lists own friends -> allowed', async () => {
      await assertSucceeds(getDocs(collection(as('alice'), 'profiles/alice/friends')));
    });
    it('owner gets one friend doc -> allowed', async () => {
      await assertSucceeds(getDoc(doc(as('alice'), 'profiles/alice/friends/bob')));
    });
    it("stranger (carol) lists alice's friends -> denied", async () => {
      await assertFails(getDocs(collection(as('carol'), 'profiles/alice/friends')));
    });
    it("stranger gets alice's friend doc for bob -> denied", async () => {
      await assertFails(getDoc(doc(as('carol'), 'profiles/alice/friends/bob')));
    });
    it("friend (bob) lists alice's friends -> denied", async () => {
      await assertFails(getDocs(collection(as('bob'), 'profiles/alice/friends')));
    });
    it("friend (bob) gets his own entry in alice's list -> denied", async () => {
      await assertFails(getDoc(doc(as('bob'), 'profiles/alice/friends/bob')));
    });
    it('unauthenticated list -> denied', async () => {
      await assertFails(getDocs(collection(anon(), 'profiles/alice/friends')));
    });
    it('collection-group query over all friends -> denied', async () => {
      await assertFails(getDocs(collectionGroup(as('carol'), 'friends')));
    });
  });

  describe('create', () => {
    it('mutual add in one batch (carol adds alice) -> allowed', async () => {
      await assertSucceeds(mutualAdd(as('carol'), 'carol', 'alice'));
    });
    it('mutual add in one transaction -> allowed', async () => {
      const db = as('carol');
      await assertSucceeds(
        runTransaction(db, async (tx) => {
          tx.set(doc(db, 'profiles/carol/friends/alice'), { addedAt: serverTimestamp() });
          tx.set(doc(db, 'profiles/alice/friends/carol'), { addedAt: serverTimestamp() });
        }),
      );
    });
    it('owner adds a friend to own list only -> allowed', async () => {
      await assertSucceeds(
        setDoc(doc(as('carol'), 'profiles/carol/friends/alice'), { addedAt: serverTimestamp() }),
      );
    });
    it('new user creates profile, code and a mutual friendship in one batch -> allowed', async () => {
      const db = as('dave');
      const b = writeBatch(db);
      b.set(doc(db, 'profiles/dave'), newProfile());
      b.set(doc(db, 'codes/DAVE23'), { uid: 'dave' });
      b.set(doc(db, 'profiles/dave/friends/alice'), { addedAt: serverTimestamp() });
      b.set(doc(db, 'profiles/alice/friends/dave'), { addedAt: serverTimestamp() });
      await assertSucceeds(b.commit());
    });
    it("stranger adds self to alice's list without the reverse doc -> denied", async () => {
      await assertFails(
        setDoc(doc(as('carol'), 'profiles/alice/friends/carol'), { addedAt: serverTimestamp() }),
      );
    });
    it("stranger adds self to alice's list with a reverse doc to someone else -> denied", async () => {
      const db = as('carol');
      const b = writeBatch(db);
      b.set(doc(db, 'profiles/alice/friends/carol'), { addedAt: serverTimestamp() });
      b.set(doc(db, 'profiles/carol/friends/bob'), { addedAt: serverTimestamp() });
      await assertFails(b.commit());
    });
    it("stranger adds a third party (bob) to alice's list -> denied", async () => {
      await assertFails(
        setDoc(doc(as('carol'), 'profiles/alice/friends/bob'), { addedAt: serverTimestamp() }),
      );
    });
    it('stranger writes a mutual pair between two other users -> denied', async () => {
      await assertFails(mutualAdd(as('carol'), 'bob', 'dave'));
    });
    it('owner adds a uid with no profile -> denied', async () => {
      await assertFails(
        setDoc(doc(as('alice'), 'profiles/alice/friends/ghost'), { addedAt: serverTimestamp() }),
      );
    });
    it('mutual add with a uid that has no profile -> denied', async () => {
      await assertFails(mutualAdd(as('alice'), 'alice', 'ghost'));
    });
    it('user with no profile (dave) mutual-adds alice -> denied', async () => {
      await assertFails(mutualAdd(as('dave'), 'dave', 'alice'));
    });
    it('owner adds self as friend -> denied', async () => {
      await assertFails(
        setDoc(doc(as('alice'), 'profiles/alice/friends/alice'), { addedAt: serverTimestamp() }),
      );
    });
    it('addedAt set to a client timestamp -> denied', async () => {
      await assertFails(mutualAdd(as('carol'), 'carol', 'alice', { addedAt: Timestamp.now() }));
    });
    it('reverse doc with a client timestamp -> denied', async () => {
      await assertFails(
        mutualAdd(
          as('carol'),
          'carol',
          'alice',
          { addedAt: serverTimestamp() },
          { addedAt: SEED_TIME },
        ),
      );
    });
    it('extra key on the friend doc -> denied', async () => {
      await assertFails(
        mutualAdd(as('carol'), 'carol', 'alice', { addedAt: serverTimestamp(), note: 'hi' }),
      );
    });
    it('missing addedAt -> denied', async () => {
      await assertFails(
        setDoc(doc(as('carol'), 'profiles/carol/friends/alice'), {}),
      );
    });
    it('re-add self to a list after the other side unfriended only their half -> allowed', async () => {
      // bob removed alice from his list; alice's half (alice -> bob) remains.
      await assertSucceeds(deleteDoc(doc(as('bob'), 'profiles/bob/friends/alice')));
      await assertSucceeds(
        setDoc(doc(as('alice'), 'profiles/bob/friends/alice'), { addedAt: serverTimestamp() }),
      );
    });
    it('re-add with both halves while one half still exists -> denied (set on it is an update)', async () => {
      await assertSucceeds(deleteDoc(doc(as('bob'), 'profiles/bob/friends/alice')));
      await assertFails(mutualAdd(as('alice'), 'alice', 'bob'));
    });
    it('unauthenticated mutual add -> denied', async () => {
      await assertFails(mutualAdd(anon(), 'carol', 'alice'));
    });
  });

  describe('update / delete', () => {
    it('owner rewrites an existing friend doc -> denied (no updates)', async () => {
      await assertFails(
        setDoc(doc(as('alice'), 'profiles/alice/friends/bob'), { addedAt: serverTimestamp() }),
      );
    });
    it('friend rewrites his entry in the other list -> denied', async () => {
      await assertFails(
        setDoc(doc(as('bob'), 'profiles/alice/friends/bob'), { addedAt: serverTimestamp() }),
      );
    });
    it('owner unfriends (deletes from own list) -> allowed', async () => {
      await assertSucceeds(deleteDoc(doc(as('alice'), 'profiles/alice/friends/bob')));
    });
    it("friend removes himself from the other's list -> allowed", async () => {
      await assertSucceeds(deleteDoc(doc(as('bob'), 'profiles/alice/friends/bob')));
    });
    it('unfriend both halves in one batch -> allowed', async () => {
      const db = as('bob');
      const b = writeBatch(db);
      b.delete(doc(db, 'profiles/bob/friends/alice'));
      b.delete(doc(db, 'profiles/alice/friends/bob'));
      await assertSucceeds(b.commit());
    });
    it("stranger deletes from alice's list -> denied", async () => {
      await assertFails(deleteDoc(doc(as('carol'), 'profiles/alice/friends/bob')));
    });
    it('unauthenticated delete -> denied', async () => {
      await assertFails(deleteDoc(doc(anon(), 'profiles/alice/friends/bob')));
    });
  });
});

// ===================================================================
describe('profiles/{uid}/games/{gameId}', () => {
  const game = (over = {}) => ({ json: '{"rounds":[1,2,3]}', playedAt: SEED_TIME, ...over });

  it('owner gets a game -> allowed', async () => {
    await assertSucceeds(getDoc(doc(as('alice'), 'profiles/alice/games/g1')));
  });
  it('owner lists games -> allowed', async () => {
    await assertSucceeds(getDocs(collection(as('alice'), 'profiles/alice/games')));
  });
  it('owner creates a game -> allowed', async () => {
    await assertSucceeds(setDoc(doc(as('alice'), 'profiles/alice/games/g2'), game()));
  });
  it('owner creates a game with serverTimestamp playedAt -> allowed', async () => {
    await assertSucceeds(
      setDoc(doc(as('alice'), 'profiles/alice/games/g2'), game({ playedAt: serverTimestamp() })),
    );
  });
  it('owner creates json of exactly 100000 chars -> allowed', async () => {
    await assertSucceeds(
      setDoc(doc(as('alice'), 'profiles/alice/games/g2'), game({ json: 'x'.repeat(100000) })),
    );
  });
  it('owner creates json of 100001 chars -> denied', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'profiles/alice/games/g2'), game({ json: 'x'.repeat(100001) })),
    );
  });
  it('owner creates json as a map -> denied', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'profiles/alice/games/g2'), game({ json: { rounds: [] } })),
    );
  });
  it('owner creates playedAt as a string -> denied', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'profiles/alice/games/g2'), game({ playedAt: '2026-01-01' })),
    );
  });
  it('owner creates without playedAt -> denied', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'profiles/alice/games/g2'), omit(game(), 'playedAt')),
    );
  });
  it('owner creates without json -> denied', async () => {
    await assertFails(setDoc(doc(as('alice'), 'profiles/alice/games/g2'), omit(game(), 'json')));
  });
  it('owner creates with an extra key -> denied', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'profiles/alice/games/g2'), game({ winner: 'alice' })),
    );
  });
  it('owner updates a game -> allowed', async () => {
    await assertSucceeds(
      updateDoc(doc(as('alice'), 'profiles/alice/games/g1'), { json: '{"rounds":[9]}' }),
    );
  });
  it('owner updates json to 100001 chars -> denied', async () => {
    await assertFails(
      updateDoc(doc(as('alice'), 'profiles/alice/games/g1'), { json: 'x'.repeat(100001) }),
    );
  });
  it('owner updates with an extra key -> denied', async () => {
    await assertFails(updateDoc(doc(as('alice'), 'profiles/alice/games/g1'), { extra: 1 }));
  });
  it('owner deletes a game -> allowed', async () => {
    await assertSucceeds(deleteDoc(doc(as('alice'), 'profiles/alice/games/g1')));
  });
  it("stranger (carol) gets alice's game -> denied", async () => {
    await assertFails(getDoc(doc(as('carol'), 'profiles/alice/games/g1')));
  });
  it("friend (bob) gets alice's game -> denied", async () => {
    await assertFails(getDoc(doc(as('bob'), 'profiles/alice/games/g1')));
  });
  it("stranger lists alice's games -> denied", async () => {
    await assertFails(getDocs(collection(as('carol'), 'profiles/alice/games')));
  });
  it("stranger creates in alice's games -> denied", async () => {
    await assertFails(setDoc(doc(as('carol'), 'profiles/alice/games/g2'), game()));
  });
  it("stranger updates alice's game -> denied", async () => {
    await assertFails(updateDoc(doc(as('carol'), 'profiles/alice/games/g1'), { json: '{}' }));
  });
  it("stranger deletes alice's game -> denied", async () => {
    await assertFails(deleteDoc(doc(as('carol'), 'profiles/alice/games/g1')));
  });
  it('unauthenticated get -> denied', async () => {
    await assertFails(getDoc(doc(anon(), 'profiles/alice/games/g1')));
  });
  it('collection-group query over all games -> denied', async () => {
    await assertFails(getDocs(collectionGroup(as('carol'), 'games')));
  });
});

// ===================================================================
describe('everything else', () => {
  it('signed-in read of an unknown collection -> denied', async () => {
    await assertFails(getDoc(doc(as('alice'), 'users/alice')));
  });
  it('signed-in write to an unknown collection -> denied', async () => {
    await assertFails(setDoc(doc(as('alice'), 'users/alice'), { a: 1 }));
  });
  it('owner write to an unknown subcollection of own profile -> denied', async () => {
    await assertFails(setDoc(doc(as('alice'), 'profiles/alice/settings/x'), { a: 1 }));
  });
  it('owner read of an unknown subcollection of own profile -> denied', async () => {
    await assertFails(getDocs(collection(as('alice'), 'profiles/alice/settings')));
  });
  it('subcollection under codes -> denied', async () => {
    await assertFails(setDoc(doc(as('alice'), 'codes/ALCE23/x/y'), { a: 1 }));
  });
  it('unauthenticated write to an unknown collection -> denied', async () => {
    await assertFails(setDoc(doc(anon(), 'anything/x'), { a: 1 }));
  });
});
