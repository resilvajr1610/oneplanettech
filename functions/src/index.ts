import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const atualizarPublicacoesCurso = functions.firestore.document('Publicacoes/{publicacaoId}').onWrite((snap, context) => {

  if (snap.before.data()?.turma !== undefined && snap.before.data()?.curso == undefined) {

    return admin.firestore().collection('Turmas')
      .where('unidade', '==', snap.before.data()?.unidade)
      .where('turma', '==', snap.before.data()?.turma)
      .get().then((turmaDoc) => {
        if (turmaDoc.empty) {
          console.log('Curso não encontrado');
          return;

        } else {
          const turmacerta = turmaDoc.docs[0];
          snap.after.ref.update({ curso: turmacerta.data()['curso'] });
          return admin.firestore().collection('TurmasTeste').add({
            curso: turmacerta.data()['curso'],
            id: snap.before.id,
          });
          //  return
        }
      });
  } else {
    return;
  }
});