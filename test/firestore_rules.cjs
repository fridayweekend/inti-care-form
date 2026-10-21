const fs = require('node:fs');
const {initializeTestEnvironment, assertSucceeds, assertFails} =
  require('../.tools/node_modules/@firebase/rules-unit-testing');
const {doc, setDoc, getDoc, updateDoc, deleteDoc, Timestamp, serverTimestamp} =
  require('../.tools/node_modules/firebase/firestore');

(async () => {
  const env = await initializeTestEnvironment({
    projectId: 'demo-inti-care',
    firestore: {rules: fs.readFileSync('firestore.rules', 'utf8')},
  });
  let passed = 0;
  const check = async (name, operation) => {
    await operation;
    console.log(`PASS ${++passed}: ${name}`);
  };
  try {
    const owner = env.authenticatedContext('student-a').firestore();
    const other = env.authenticatedContext('student-b').firestore();
    const guest = env.unauthenticatedContext().firestore();
    const valid = {
      ownerUid:'student-a', studentName:'Alex Tan', studentId:'INTI-2026001',
      email:'alex@student.example.edu', phone:'', serviceCategory:'Library services',
      subject:'Library reading lamp', description:'The desk lamp in the study area needs maintenance.',
      urgency:'Normal', preferredContact:'Email',
      preferredDate:Timestamp.fromMillis(Date.now() + 86400000),
      declaration:true, status:'submitted', createdAt:serverTimestamp(), location:'',
    };
    await check('owner creates valid request', assertSucceeds(setDoc(doc(owner,'campusRequests/valid'),valid)));
    await check('owner retrieves request', assertSucceeds(getDoc(doc(owner,'campusRequests/valid'))));
    await check('other owner cannot read', assertFails(getDoc(doc(other,'campusRequests/valid'))));
    await check('guest cannot read', assertFails(getDoc(doc(guest,'campusRequests/valid'))));
    await check('guest cannot create', assertFails(setDoc(doc(guest,'campusRequests/guest'),valid)));
    await check('cannot impersonate another owner', assertFails(setDoc(doc(other,'campusRequests/spoof'),valid)));
    await check('owner cannot update', assertFails(updateDoc(doc(owner,'campusRequests/valid'),{subject:'Changed'})));
    await check('owner cannot delete', assertFails(deleteDoc(doc(owner,'campusRequests/valid'))));
    for (const [name, change] of Object.entries({
      studentId:{studentId:'bad'}, email:{email:'invalid'}, phone:{phone:'abc'},
      category:{serviceCategory:'Unknown'}, urgency:{urgency:'Critical'},
      contact:{preferredContact:'Phone'}, consent:{declaration:false},
      date:{preferredDate:Timestamp.fromMillis(0)}, timestamp:{createdAt:Timestamp.fromMillis(0)},
      length:{description:'short'}, extra:{unexpected:true},
      location:{serviceCategory:'Accommodation',location:''},
    })) {
      await check(`reject invalid ${name}`, assertFails(setDoc(doc(owner,`campusRequests/${name}`),{...valid,...change})));
    }
    console.log(`All ${passed} security rule checks passed.`);
  } finally { await env.cleanup(); }
})().catch(error => {console.error(error);process.exitCode=1;});
