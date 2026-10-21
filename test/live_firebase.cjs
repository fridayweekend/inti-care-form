// Explicit live-project verification using fictional data.
// Creates one retained test record and two anonymous test identities.
const fs = require('node:fs');
const { initializeApp, deleteApp } = require('../.tools/node_modules/firebase/app');
const { getAuth, signInAnonymously } = require('../.tools/node_modules/firebase/auth');
const { getFirestore, collection, doc, setDoc, getDocFromServer, getDocsFromServer,
  query, where, disableNetwork, enableNetwork, Timestamp, serverTimestamp, terminate } =
  require('../.tools/node_modules/firebase/firestore');
const configSource = fs.readFileSync('lib/firebase_options.dart', 'utf8');
const config = Object.fromEntries(['apiKey','appId','projectId','messagingSenderId'].map(
  key => [key, configSource.match(new RegExp(`${key}: '([^']+)'`))[1]]
));
const report = {project:config.projectId, checks:[]};
const apps = [], databases = [];
function pass(name) {report.checks.push({name, result:'passed'});console.log(`PASS: ${name}`);}
async function denied(action) {
  try {await action();} catch(e) {
    if(e.code === 'permission-denied') return;
    throw e;
  }
  throw Error('Expected permission-denied');
}
(async()=>{
  const app = initializeApp(config, 'live-offline-test'); apps.push(app);
  const user = (await signInAnonymously(getAuth(app))).user;
  const db = getFirestore(app); databases.push(db);
  const ref = doc(collection(db,'campusRequests'));
  const payload = {
    ownerUid:user.uid, studentName:'Alex Test', studentId:'INTI-2026002',
    email:'offline@student.example.edu', phone:'', serviceCategory:'IT & Wi-Fi',
    subject:'Offline sync verification', description:'Fictional assessment record verifying that queued writes synchronize without duplicate IDs.',
    urgency:'Low', preferredContact:'Email', preferredDate:Timestamp.fromMillis(Date.now()+86400000),
    declaration:true, status:'submitted', createdAt:serverTimestamp(), location:'',
  };
  await disableNetwork(db);
  let acknowledged = false;
  const write = setDoc(ref,payload).then(()=>{acknowledged=true;});
  await new Promise(resolve=>setTimeout(resolve,2000));
  if(acknowledged) throw Error('Write acknowledged while offline');
  pass('Offline write remains pending without premature acknowledgement');
  await enableNetwork(db);
  await write;
  pass('Original queued write acknowledged after reconnection');
  const saved = await getDocFromServer(ref);
  if(!saved.exists() || !(saved.data().createdAt instanceof Timestamp)) throw Error('Missing record/server timestamp');
  report.requestId=ref.id;
  pass('Original document ID retrieved with server timestamp');
  const records=await getDocsFromServer(query(collection(db,'campusRequests'),where('ownerUid','==',user.uid)));
  if(records.size!==1) throw Error('Duplicate documents found');
  pass('Exactly one document exists for the test owner');
  const otherApp=initializeApp(config,'live-other-owner');apps.push(otherApp);
  await signInAnonymously(getAuth(otherApp));
  const otherDb=getFirestore(otherApp);databases.push(otherDb);
  await denied(()=>getDocFromServer(doc(otherDb,'campusRequests','mXzwP1vZRivvHfBMUIj4')));
  pass('Different anonymous owner cannot read the Flutter-created request');
  await denied(()=>setDoc(doc(collection(db,'campusRequests')),{...payload,declaration:false}));
  pass('Live rules reject a write without declaration');
})().catch(error=>{
  report.error=String(error);
  process.exitCode=1;
}).finally(async()=>{
  report.checkedAt=new Date().toISOString();
  fs.mkdirSync('docs/firebase-evidence',{recursive:true});
  fs.writeFileSync('docs/firebase-evidence/live-sdk-results.json',JSON.stringify(report,null,2));
  await Promise.all(databases.map(db=>terminate(db)));
  await Promise.all(apps.map(app=>deleteApp(app)));
  if(report.error) console.error(report.error);
});
