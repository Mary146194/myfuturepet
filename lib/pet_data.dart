// ============================================================
// PET DATA
// ============================================================
// ONE SHARED PET DATA SOURCE FOR THE WHOLE APP.
//
// Home Screen uses this.
// Pets Screen uses this.
// Pet Details Screen receives the same pet map.
//
// If you add/edit a pet here, the change is available
// throughout the app.
// ============================================================

class PetData {
  static final List<Map<String, dynamic>> pets = [
    {
      'name': 'Bella',
      'breed': 'Golden Retriever',
      'age': '2 yrs',
      'gender': 'Female',
      'status': 'Available',
      'vaccinated': true,
      'kidFriendly': true,
      'energy': 'Good w/ Kids',
      'image':
          'https://images.unsplash.com/photo-1552053831-71594a27632d?w=1200',
      'category': 'Dogs',
      'weight': '65 lbs',
      'vaccinationStatus': 'Up to date',
      'personality': [
        'Friendly',
        'Active',
        'Good with Kids',
      ],
      'about':
          'Bella is a sweet, energetic dog who loves everyone she meets. She was brought to our shelter when her previous owners had to move overseas. She thrives on outdoor activities and would make a perfect companion for an active family. She already knows basic commands and is fully house-trained.',
      'shelter':
          'JAGNA ANIMAL LOVER AND RESCUE GROUP',
      'shelterPhone': 'Contact Shelter',
    },

    {
      'name': 'Oliver',
      'breed': 'Domestic Longhair',
      'age': '4 yrs',
      'gender': 'Male',
      'status': 'Pending',
      'vaccinated': true,
      'kidFriendly': false,
      'energy': 'Calm',
      'image':
          'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=1200',
      'category': 'Cats',
      'weight': '11 lbs',
      'vaccinationStatus': 'Up to date',
      'personality': [
        'Calm',
        'Gentle',
        'Independent',
      ],
      'about':
          'Oliver is a calm and gentle cat who enjoys quiet environments and relaxing indoors. He is affectionate once he gets comfortable and would be a wonderful companion for someone looking for a peaceful pet.',
      'shelter':
          'JAGNA ANIMAL LOVER AND RESCUE GROUP',
      'shelterPhone': 'Contact Shelter',
    },

    {
      'name': 'Scout',
      'breed': 'Terrier Mix',
      'age': '1 yr',
      'gender': 'Male',
      'status': 'Available',
      'vaccinated': true,
      'kidFriendly': false,
      'energy': 'High Energy',
      'image':
          'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=1200',
      'category': 'Dogs',
      'weight': '22 lbs',
      'vaccinationStatus': 'Up to date',
      'personality': [
        'Playful',
        'Active',
        'Loyal',
      ],
      'about':
          'Scout is a playful young dog full of energy. He loves exploring, playing outdoors, and spending time with people. He would be a great match for an active family who can give him plenty of exercise and attention.',
      'shelter':
          'JAGNA ANIMAL LOVER AND RESCUE GROUP',
      'shelterPhone': 'Contact Shelter',
    },

    {
      'name': 'Luna',
      'breed': 'Calico',
      'age': '3 yrs',
      'gender': 'Female',
      'status': 'Available',
      'vaccinated': true,
      'kidFriendly': false,
      'energy': 'Indoor Only',
      'image':
          'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=1200',
      'category': 'Cats',
      'weight': '9 lbs',
      'vaccinationStatus': 'Up to date',
      'personality': [
        'Gentle',
        'Quiet',
        'Affectionate',
      ],
      'about':
          'Luna is a gentle and affectionate cat who prefers a calm indoor environment. She enjoys relaxing in cozy spaces and slowly building trust with her humans.',
      'shelter':
          'JAGNA ANIMAL LOVER AND RESCUE GROUP',
      'shelterPhone': 'Contact Shelter',
    },
  ];
}