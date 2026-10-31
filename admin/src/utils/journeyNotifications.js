import { supabase } from '../config/supabaseClient';

// The mobile app's "Adoption Journey" road reads its stage from application
// status, the meet & greet appointment, and pet status. These messages land
// in the adopter's notifications so each move forward reaches them.
const APPLICATION_MESSAGES = {
  under_review: {
    title: 'Reviewing your details',
    body: (pet) => `Your application for ${pet} is now being reviewed by our volunteers.`,
  },
  approved: {
    title: 'Approved! Time to schedule your interview',
    body: (pet) => `Great news! Your application for ${pet} was approved. Book a meet & greet in the app.`,
  },
  rejected: {
    title: 'Application update',
    body: (pet) => `We could not move forward with your application for ${pet}. You can still apply for another pet.`,
  },
};

async function notify(userId, title, body, data) {
  if (!userId) return;
  try {
    const { error } = await supabase.from('notifications').insert({
      user_id: userId,
      title,
      body,
      type: 'adoption_status',
      data,
      read_at: null,
    });
    if (error) throw error;
  } catch (e) {
    console.error('Failed to dispatch adoption journey notification:', e);
  }
}

export async function notifyApplicationStatus(application, newStatus) {
  const message = APPLICATION_MESSAGES[newStatus];
  if (!application || !message || application.status === newStatus) return;
  const petName = application.pet?.name || 'your future pet';
  await notify(application.applicant_id, message.title, message.body(petName), {
    application_id: application.id,
    pet_id: application.pet_id,
    status: newStatus,
  });
}

// Marking a pet adopted completes the journey for its approved adopter(s).
export async function notifyPetAdopted(petId, petName) {
  try {
    const { data, error } = await supabase
      .from('adoption_applications')
      .select('id, applicant_id')
      .eq('pet_id', petId)
      .eq('status', 'approved');
    if (error) throw error;
    await Promise.all((data || []).map((app) => notify(
      app.applicant_id,
      `Welcome home, ${petName || 'friend'}!`,
      `${petName || 'Your pet'} is officially part of your family. Thank you for adopting!`,
      { application_id: app.id, pet_id: petId, status: 'adopted' },
    )));
  } catch (e) {
    console.error('Failed to notify adopters of adoption:', e);
  }
}
