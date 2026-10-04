
// import 'package:flutter/material.dart';

// import '../saved_pet_store.dart';
// import 'pet_details_screen.dart';


// class PetsScreen extends StatefulWidget {
//   final String initialCategory;
//   final bool autoFocusSearch;

//   const PetsScreen({
//     super.key,
//     this.initialCategory = 'All',
//     this.autoFocusSearch = false,
//   });

//   @override
//   State<PetsScreen> createState() => _PetsScreenState();
// }

// class _PetsScreenState extends State<PetsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor = Color(0xFFA94327);
//   static const Color backgroundColor = Color(0xFFF5FAFD);
//   static const Color darkText = Color(0xFF062B35);

//   static const Color tealColor = Color(0xFF008F82);
//   static const Color pendingColor = Color(0xFFB65C32);

//   static const Color lightBlue = Color(0xFFE7F5FA);
//   static const Color borderColor = Color(0xFFD8E2E5);
//   static const Color secondaryText = Color(0xFF697578);

//   // ============================================================
//   // SEARCH
//   // ============================================================

//   final TextEditingController _searchController =
//       TextEditingController();

//   final FocusNode _searchFocusNode = FocusNode();

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Dogs',
//     'Cats',
//   ];

//   // ============================================================
//   // EXTRA FILTERS
//   // ============================================================

//   String selectedBreed = 'All Breeds';
//   String selectedAge = 'Any Age';
//   String selectedGender = 'Any Gender';
//   String selectedStatus = 'All Status';

//   // ============================================================
//   // LIKES
//   // ============================================================
//   //
//   // IMPORTANT:
//   // Heart = LIKE only.
//   // It does NOT save/favorite the pet.
//   //
//   // ============================================================

//   final Set<String> _likedPets = {};

//   // ============================================================
//   // PET DATA
//   // ============================================================

//   final List<Map<String, dynamic>> pets = [
//     {
//       'name': 'Bella',
//       'breed': 'Golden Retriever',
//       'age': '2 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': true,
//       'energy': 'Good w/ Kids',

//       // NEW
//       'behavior': 'Active',
//       'personalityShort': 'Friendly',
//       'likes': 12,

//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=1200',
//       'category': 'Dogs',

//       'weight': '65 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Friendly',
//         'Active',
//         'Good with Kids',
//       ],
//       'about':
//           'Bella is a sweet, energetic dog who loves everyone she meets. She was brought to our shelter when her previous owners had to move overseas. She thrives on outdoor activities and would make a perfect companion for an active family. She already knows basic commands and is fully house-trained.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Domestic Longhair',
//       'age': '4 yrs',
//       'gender': 'Male',
//       'status': 'Pending',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Calm',

//       // NEW
//       'behavior': 'Calm',
//       'personalityShort': 'Shy',
//       'likes': 8,

//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=1200',
//       'category': 'Cats',

//       'weight': '11 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Calm',
//         'Gentle',
//         'Independent',
//       ],
//       'about':
//           'Oliver is a calm and gentle cat who enjoys quiet environments and relaxing indoors. He is affectionate once he gets comfortable and would be a wonderful companion for someone looking for a peaceful pet.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Scout',
//       'breed': 'Terrier Mix',
//       'age': '1 yr',
//       'gender': 'Male',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'High Energy',

//       // NEW
//       'behavior': 'High Energy',
//       'personalityShort': 'Playful',
//       'likes': 15,

//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=1200',
//       'category': 'Dogs',

//       'weight': '22 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Playful',
//         'Active',
//         'Loyal',
//       ],
//       'about':
//           'Scout is a playful young dog full of energy. He loves exploring, playing outdoors, and spending time with people. He would be a great match for an active family who can give him plenty of exercise and attention.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Calico',
//       'age': '3 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Indoor Only',

//       // NEW
//       'behavior': 'Quiet',
//       'personalityShort': 'Affectionate',
//       'likes': 10,

//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=1200',
//       'category': 'Cats',

//       'weight': '9 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Gentle',
//         'Quiet',
//         'Affectionate',
//       ],
//       'about':
//           'Luna is a gentle and affectionate cat who prefers a calm indoor environment. She enjoys relaxing in cozy spaces and slowly building trust with her humans.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//   ];

//   // ============================================================
//   // LIFECYCLE
//   // ============================================================

//   @override
//   void initState() {
//     super.initState();

//     // Get the category sent from HomeScreen
//     selectedCategory = widget.initialCategory;

//     // Automatically focus the search bar when requested
//     if (widget.autoFocusSearch) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) {
//           _searchFocusNode.requestFocus();
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   return SingleChildScrollView(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.fromLTRB(
//                       16,
//                       14,
//                       16,
//                       28,
//                     ),
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(
//                         minHeight: constraints.maxHeight,
//                       ),
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           _buildPageTitle(),
//                           const SizedBox(height: 14),
//                           _buildSearchBar(),
//                           const SizedBox(height: 12),
//                           _buildCategoryFilter(),
//                           const SizedBox(height: 14),
//                           _buildFilterButtons(),
//                           const SizedBox(height: 18),
//                           _buildResultsLabel(),
//                           const SizedBox(height: 10),
//                           _buildPetList(),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PAGE TITLE
//   // ============================================================

//   Widget _buildPageTitle() {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Find Your Future Pet',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             height: 1.15,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           'Meet pets looking for a loving home.',
//           style: TextStyle(
//             color: secondaryText,
//             fontSize: 12,
//             height: 1.35,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       height: 58,
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16,
//       ),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE2E8EA),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // PROFILE
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFD9E1E4),
//                 width: 1,
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           // APP NAME
//           const Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // NOTIFICATION
//           _buildHeaderButton(
//             icon: Icons.notifications_none_rounded,
//             onTap: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER BUTTON
//   // ============================================================

//   Widget _buildHeaderButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(50),
//         child: SizedBox(
//           width: 40,
//           height: 40,
//           child: Icon(
//             icon,
//             color: darkText,
//             size: 22,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _buildSearchBar() {
//     return Container(
//       width: double.infinity,
//       height: 48,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(
//           color: const Color(0xFFE1E8EA),
//           width: 1,
//         ),
//       ),
//       child: TextField(
//         controller: _searchController,
//         focusNode: _searchFocusNode,
//         onChanged: (_) {
//           setState(() {});
//         },
//         textInputAction: TextInputAction.search,
//         style: const TextStyle(
//           color: darkText,
//           fontSize: 13,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: const InputDecoration(
//           hintText: 'Search by name or breed',
//           hintStyle: TextStyle(
//             color: Color(0xFF92999B),
//             fontSize: 12,
//           ),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             size: 19,
//             color: Color(0xFF7C8588),
//           ),
//           prefixIconConstraints: BoxConstraints(
//             minWidth: 45,
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             vertical: 14,
//             horizontal: 8,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY FILTER
//   // ============================================================

//   Widget _buildCategoryFilter() {
//     return Row(
//       children: categories.map((category) {
//         final bool selected =
//             selectedCategory == category;

//         return Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 3,
//             ),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration:
//                     const Duration(milliseconds: 180),
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : lightBlue,
//                   borderRadius:
//                       BorderRadius.circular(22),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // FILTER BUTTONS
//   // ============================================================

//   Widget _buildFilterButtons() {
//     return SizedBox(
//       height: 38,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         physics:
//             const BouncingScrollPhysics(),
//         children: [
//           _buildSmallFilter(
//             label: selectedBreed == 'All Breeds'
//                 ? 'Breed'
//                 : selectedBreed,
//             active:
//                 selectedBreed != 'All Breeds',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Breed',
//                 currentValue: selectedBreed,
//                 options: const [
//                   'All Breeds',
//                   'Golden Retriever',
//                   'Domestic Longhair',
//                   'Terrier Mix',
//                   'Calico',
//                 ],
//                 onSelected: (value) {
//                   setState(() {
//                     selectedBreed = value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildSmallFilter(
//             label: selectedAge == 'Any Age'
//                 ? 'Age'
//                 : selectedAge,
//             active:
//                 selectedAge != 'Any Age',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Age',
//                 currentValue: selectedAge,
//                 options: const [
//                   'Any Age',
//                   'Under 1 year',
//                   '1 - 3 years',
//                   '4+ years',
//                 ],
//                 onSelected: (value) {
//                   setState(() {
//                     selectedAge = value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildSmallFilter(
//             label: selectedGender == 'Any Gender'
//                 ? 'Gender'
//                 : selectedGender,
//             active:
//                 selectedGender != 'Any Gender',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Gender',
//                 currentValue: selectedGender,
//                 options: const [
//                   'Any Gender',
//                   'Male',
//                   'Female',
//                 ],
//                 onSelected: (value) {
//                   setState(() {
//                     selectedGender = value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildSmallFilter(
//             label: selectedStatus == 'All Status'
//                 ? 'Status'
//                 : selectedStatus,
//             active:
//                 selectedStatus != 'All Status',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Status',
//                 currentValue: selectedStatus,
//                 options: const [
//                   'All Status',
//                   'Available',
//                   'Pending',
//                 ],
//                 onSelected: (value) {
//                   setState(() {
//                     selectedStatus = value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildClearFilterButton(),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SMALL FILTER
//   // ============================================================

//   Widget _buildSmallFilter({
//     required String label,
//     required bool active,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 38,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 13,
//         ),
//         decoration: BoxDecoration(
//           color: active
//               ? const Color(0xFFFFEEE8)
//               : Colors.white,
//           borderRadius:
//               BorderRadius.circular(10),
//           border: Border.all(
//             color: active
//                 ? primaryColor
//                 : borderColor,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: active
//                     ? primaryColor
//                     : darkText,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(width: 3),
//             Icon(
//               Icons.keyboard_arrow_down_rounded,
//               size: 15,
//               color: active
//                   ? primaryColor
//                   : secondaryText,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CLEAR FILTER BUTTON
//   // ============================================================

//   Widget _buildClearFilterButton() {
//     final bool hasFilter =
//         selectedBreed != 'All Breeds' ||
//             selectedAge != 'Any Age' ||
//             selectedGender != 'Any Gender' ||
//             selectedStatus != 'All Status';

//     if (!hasFilter) {
//       return const SizedBox.shrink();
//     }

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedBreed = 'All Breeds';
//           selectedAge = 'Any Age';
//           selectedGender = 'Any Gender';
//           selectedStatus = 'All Status';
//         });
//       },
//       child: Container(
//         height: 38,
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 12,
//         ),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: const Color(0xFFEFF3F4),
//           borderRadius:
//               BorderRadius.circular(10),
//         ),
//         child: const Text(
//           'Clear',
//           style: TextStyle(
//             color: secondaryText,
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RESULTS LABEL
//   // ============================================================

//   Widget _buildResultsLabel() {
//     final List<Map<String, dynamic>> filtered =
//         _getFilteredPets();

//     return Row(
//       children: [
//         Text(
//           '${filtered.length} ${filtered.length == 1 ? 'pet' : 'pets'} found',
//           style: const TextStyle(
//             color: darkText,
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const Spacer(),
//         const Icon(
//           Icons.tune_rounded,
//           size: 15,
//           color: secondaryText,
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // FILTERED PETS
//   // ============================================================

//   List<Map<String, dynamic>> _getFilteredPets() {
//     final String searchText =
//         _searchController.text
//             .trim()
//             .toLowerCase();

//     return pets.where((pet) {
//       final bool categoryMatch =
//           selectedCategory == 'All' ||
//               pet['category'] ==
//                   selectedCategory;

//       final bool searchMatch =
//           searchText.isEmpty ||
//               pet['name']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText) ||
//               pet['breed']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText);

//       final bool breedMatch =
//           selectedBreed == 'All Breeds' ||
//               pet['breed'] ==
//                   selectedBreed;

//       final bool ageMatch =
//           _matchesAge(
//         pet['age'].toString(),
//       );

//       final bool genderMatch =
//           selectedGender == 'Any Gender' ||
//               pet['gender'] ==
//                   selectedGender;

//       final bool statusMatch =
//           selectedStatus == 'All Status' ||
//               pet['status'] ==
//                   selectedStatus;

//       return categoryMatch &&
//           searchMatch &&
//           breedMatch &&
//           ageMatch &&
//           genderMatch &&
//           statusMatch;
//     }).toList();
//   }

//   // ============================================================
//   // AGE MATCH
//   // ============================================================

//   bool _matchesAge(String age) {
//     if (selectedAge == 'Any Age') {
//       return true;
//     }

//     final String numberOnly =
//         age.replaceAll(
//       RegExp(r'[^0-9.]'),
//       '',
//     );

//     final double petAge =
//         double.tryParse(numberOnly) ?? 0;

//     switch (selectedAge) {
//       case 'Under 1 year':
//         return petAge < 1;

//       case '1 - 3 years':
//         return petAge >= 1 &&
//             petAge <= 3;

//       case '4+ years':
//         return petAge >= 4;

//       default:
//         return true;
//     }
//   }

//   // ============================================================
//   // PET LIST
//   // ============================================================

//   Widget _buildPetList() {
//     final List<Map<String, dynamic>>
//         filteredPets =
//         _getFilteredPets();

//     if (filteredPets.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       children: filteredPets.map((pet) {
//         return Padding(
//           padding:
//               const EdgeInsets.only(
//             bottom: 16,
//           ),
//           child: _buildPetCard(pet),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // PET CARD
//   // ============================================================

//   Widget _buildPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     final bool isAvailable =
//         pet['status'] == 'Available';

//     final String petName =
//         pet['name'].toString();

//     final bool isLiked =
//         _likedPets.contains(petName);

//     // IMPORTANT:
//     // This is completely separate from _likedPets.
//     final bool isSaved =
//         SavedPetStore.isSaved(petName);

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) =>
//                 PetDetailsScreen(
//               pet: pet,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(16),
//           border: Border.all(
//             color: const Color(0xFFDCE7EA),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(
//                 0.035,
//               ),
//               blurRadius: 7,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           children: [
//             // ==================================================
//             // IMAGE
//             // ==================================================

//             AspectRatio(
//               aspectRatio: 1.35,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.network(
//                     pet['image'].toString(),
//                     fit: BoxFit.cover,
//                     alignment:
//                         Alignment.center,
//                     errorBuilder:
//                         (_, __, ___) {
//                       return Container(
//                         color:
//                             const Color(
//                           0xFFE9EEF0,
//                         ),
//                         child: Icon(
//                           pet['category'] ==
//                                   'Dogs'
//                               ? Icons.pets
//                               : Icons
//                                   .cruelty_free,
//                           color:
//                               primaryColor,
//                           size: 52,
//                         ),
//                       );
//                     },
//                   ),

//                   // ==================================================
//                   // GRADIENT
//                   // ==================================================

//                   Positioned.fill(
//                     child: DecoratedBox(
//                       decoration:
//                           BoxDecoration(
//                         gradient:
//                             LinearGradient(
//                           begin: Alignment
//                               .topCenter,
//                           end: Alignment
//                               .bottomCenter,
//                           stops: const [
//                             0.35,
//                             1.0,
//                           ],
//                           colors: [
//                             Colors
//                                 .transparent,
//                             Colors.black
//                                 .withOpacity(
//                               0.78,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ==================================================
//                   // STATUS
//                   // ==================================================

//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 10,
//                         vertical: 6,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color: isAvailable
//                             ? tealColor
//                             : pendingColor,
//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           18,
//                         ),
//                       ),
//                       child: Text(
//                         pet['status']
//                             .toString()
//                             .toUpperCase(),
//                         style:
//                             const TextStyle(
//                           color:
//                               Colors.white,
//                           fontSize: 8,
//                           fontWeight:
//                               FontWeight.bold,
//                           letterSpacing:
//                               0.3,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ==================================================
//                   // LIKE + FAVORITE BUTTONS
//                   // ==================================================

//                   Positioned(
//                     right: 11,
//                     bottom: 12,
//                     child: Row(
//                       mainAxisSize:
//                           MainAxisSize.min,
//                       children: [
//                         // ==========================================
//                         // HEART = LIKE ONLY
//                         // ==========================================

//                         Material(
//                           color:
//                               Colors.transparent,
//                           child: InkWell(
//                             onTap: () {
//                               setState(() {
//                                 final int
//                                     currentLikes =
//                                     int.tryParse(
//                                           pet['likes']
//                                               .toString(),
//                                         ) ??
//                                         0;

//                                 if (isLiked) {
//                                   _likedPets
//                                       .remove(
//                                     petName,
//                                   );

//                                   pet['likes'] =
//                                       currentLikes >
//                                               0
//                                           ? currentLikes -
//                                               1
//                                           : 0;
//                                 } else {
//                                   _likedPets.add(
//                                     petName,
//                                   );

//                                   pet['likes'] =
//                                       currentLikes +
//                                           1;
//                                 }
//                               });
//                             },
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               50,
//                             ),
//                             child:
//                                 Container(
//                               height: 38,
//                               padding:
//                                   const EdgeInsets
//                                       .symmetric(
//                                 horizontal: 9,
//                               ),
//                               decoration:
//                                   BoxDecoration(
//                                 color: Colors
//                                     .white
//                                     .withOpacity(
//                                   0.93,
//                                 ),
//                                 borderRadius:
//                                     BorderRadius
//                                         .circular(
//                                   20,
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisSize:
//                                     MainAxisSize
//                                         .min,
//                                 children: [
//                                   Icon(
//                                     isLiked
//                                         ? Icons
//                                             .favorite_rounded
//                                         : Icons
//                                             .favorite_border_rounded,
//                                     size: 20,
//                                     color: isLiked
//                                         ? primaryColor
//                                         : const Color(
//                                             0xFF667477,
//                                           ),
//                                   ),
//                                   const SizedBox(
//                                     width: 4,
//                                   ),
//                                   Text(
//                                     '${pet['likes'] ?? 0}',
//                                     style:
//                                         const TextStyle(
//                                       color:
//                                           Color(
//                                         0xFF45575B,
//                                       ),
//                                       fontSize:
//                                           10,
//                                       fontWeight:
//                                           FontWeight
//                                               .w700,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(
//                           width: 6,
//                         ),

//                         // ==========================================
//                         // PAW = FAVORITE / SAVE ONLY
//                         // ==========================================

//                         _buildFavoritePawButton(
//                           pet,
//                           isSaved,
//                         ),
//                       ],
//                     ),
//                   ),

//                   // ==================================================
//                   // PET INFORMATION
//                   // ==================================================

//                   Positioned(
//                     left: 14,

//                     // Increased from 90 to 125 because
//                     // there are now TWO buttons.
//                     right: 125,

//                     bottom: 12,
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,
//                       children: [
//                         // PET NAME
//                         Text(
//                           pet['name']
//                               .toString(),
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow
//                                   .ellipsis,
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 20,
//                             fontWeight:
//                                 FontWeight.bold,
//                             height: 1.1,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 3,
//                         ),

//                         // BREED + AGE
//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow
//                                   .ellipsis,
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 10,
//                             fontWeight:
//                                 FontWeight.w400,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 7,
//                         ),

//                         // ==================================================
//                         // BEHAVIOR + PERSONALITY
//                         // ==================================================

//                         Row(
//                           children: [
//                             // BEHAVIOR
//                             Flexible(
//                               child:
//                                   Container(
//                                 padding:
//                                     const EdgeInsets
//                                         .symmetric(
//                                   horizontal: 7,
//                                   vertical: 4,
//                                 ),
//                                 decoration:
//                                     BoxDecoration(
//                                   color: Colors
//                                       .white
//                                       .withOpacity(
//                                     0.18,
//                                   ),
//                                   borderRadius:
//                                       BorderRadius
//                                           .circular(
//                                     12,
//                                   ),
//                                   border:
//                                       Border.all(
//                                     color: Colors
//                                         .white
//                                         .withOpacity(
//                                       0.30,
//                                     ),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize:
//                                       MainAxisSize
//                                           .min,
//                                   children: [
//                                     const Icon(
//                                       Icons
//                                           .bolt_rounded,
//                                       color:
//                                           Colors
//                                               .white,
//                                       size: 11,
//                                     ),
//                                     const SizedBox(
//                                       width: 3,
//                                     ),
//                                     Flexible(
//                                       child:
//                                           Text(
//                                         pet['behavior']
//                                                 ?.toString() ??
//                                             'Active',
//                                         maxLines:
//                                             1,
//                                         overflow:
//                                             TextOverflow
//                                                 .ellipsis,
//                                         style:
//                                             const TextStyle(
//                                           color:
//                                               Colors
//                                                   .white,
//                                           fontSize:
//                                               8,
//                                           fontWeight:
//                                               FontWeight
//                                                   .w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(
//                               width: 5,
//                             ),

//                             // PERSONALITY
//                             Flexible(
//                               child:
//                                   Container(
//                                 padding:
//                                     const EdgeInsets
//                                         .symmetric(
//                                   horizontal: 7,
//                                   vertical: 4,
//                                 ),
//                                 decoration:
//                                     BoxDecoration(
//                                   color: Colors
//                                       .white
//                                       .withOpacity(
//                                     0.18,
//                                   ),
//                                   borderRadius:
//                                       BorderRadius
//                                           .circular(
//                                     12,
//                                   ),
//                                   border:
//                                       Border.all(
//                                     color: Colors
//                                         .white
//                                         .withOpacity(
//                                       0.30,
//                                     ),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize:
//                                       MainAxisSize
//                                           .min,
//                                   children: [
//                                     const Icon(
//                                       Icons
//                                           .favorite_border_rounded,
//                                       color:
//                                           Colors
//                                               .white,
//                                       size: 10,
//                                     ),
//                                     const SizedBox(
//                                       width: 3,
//                                     ),
//                                     Flexible(
//                                       child:
//                                           Text(
//                                         pet['personalityShort']
//                                                 ?.toString() ??
//                                             'Friendly',
//                                         maxLines:
//                                             1,
//                                         overflow:
//                                             TextOverflow
//                                                 .ellipsis,
//                                         style:
//                                             const TextStyle(
//                                           color:
//                                               Colors
//                                                   .white,
//                                           fontSize:
//                                               8,
//                                           fontWeight:
//                                               FontWeight
//                                                   .w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // TAGS
//             // ==================================================

//             Container(
//               width: double.infinity,
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 11,
//                 9,
//                 11,
//                 10,
//               ),
//               child: SingleChildScrollView(
//                 scrollDirection:
//                     Axis.horizontal,
//                 physics:
//                     const BouncingScrollPhysics(),
//                 child: Row(
//                   children: [
//                     if (pet['vaccinated'] ==
//                         true)
//                       _buildPetTag(
//                         icon: Icons
//                             .vaccines_rounded,
//                         text: 'Vaccinated',
//                       ),

//                     if (pet['vaccinated'] ==
//                             true &&
//                         (pet['kidFriendly'] ==
//                                 true ||
//                             pet['energy'] !=
//                                 null))
//                       const SizedBox(
//                         width: 6,
//                       ),

//                     if (pet['kidFriendly'] ==
//                         true)
//                       _buildPetTag(
//                         icon: Icons
//                             .child_friendly_rounded,
//                         text: 'Good w/ Kids',
//                       ),

//                     if (pet['kidFriendly'] ==
//                             true &&
//                         pet['energy'] !=
//                             null)
//                       const SizedBox(
//                         width: 6,
//                       ),

//                     if (pet['energy'] !=
//                         null)
//                       _buildPetTag(
//                         icon:
//                             Icons.bolt_rounded,
//                         text: pet['energy']
//                             .toString(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FAVORITE / SAVE PAW BUTTON
//   // ============================================================

//   Widget _buildFavoritePawButton(
//     Map<String, dynamic> pet,
//     bool isSaved,
//   ) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             // PAW ONLY SAVES/REMOVES THE PET.
//             //
//             // It does NOT modify:
//             // - likes
//             // - heart state
//             // - like count

//             SavedPetStore.togglePet(pet);
//           });
//         },
//         borderRadius:
//             BorderRadius.circular(50),
//         child: Container(
//           width: 38,
//           height: 38,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(
//               0.93,
//             ),
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: CustomPaint(
//               size: const Size(
//                 20,
//                 20,
//               ),
//               painter: PawPrintPainter(
//                 pawColor: isSaved
//                     ? primaryColor
//                     : const Color(
//                         0xFF667477,
//                       ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET TAG
//   // ============================================================

//   Widget _buildPetTag({
//     required IconData icon,
//     required String text,
//   }) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 5,
//       ),
//       decoration: BoxDecoration(
//         color:
//             const Color(0xFFE9F7F6),
//         borderRadius:
//             BorderRadius.circular(13),
//       ),
//       child: Row(
//         mainAxisSize:
//             MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 11,
//             color: tealColor,
//           ),
//           const SizedBox(width: 3),
//           Text(
//             text,
//             style:
//                 const TextStyle(
//               color:
//                   Color(0xFF34706C),
//               fontSize: 8,
//               fontWeight:
//                   FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       padding:
//           const EdgeInsets.symmetric(
//         vertical: 55,
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 70,
//             height: 70,
//             decoration:
//                 const BoxDecoration(
//               color: Color(0xFFE7F5FA),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.search_off_rounded,
//               size: 34,
//               color: primaryColor,
//             ),
//           ),

//           const SizedBox(height: 14),

//           const Text(
//             'No pets found',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 18,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 5),

//           const Text(
//             'Try another search or change your filters.',
//             textAlign:
//                 TextAlign.center,
//             style: TextStyle(
//               color: secondaryText,
//               fontSize: 12,
//               height: 1.4,
//             ),
//           ),

//           const SizedBox(height: 16),

//           OutlinedButton(
//             onPressed:
//                 _clearAllFilters,
//             style:
//                 OutlinedButton.styleFrom(
//               foregroundColor:
//                   primaryColor,
//               side:
//                   const BorderSide(
//                 color: primaryColor,
//               ),
//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(
//                   22,
//                 ),
//               ),
//               padding:
//                   const EdgeInsets
//                       .symmetric(
//                 horizontal: 18,
//                 vertical: 10,
//               ),
//             ),
//             child: const Text(
//               'Clear Filters',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // FILTER BOTTOM SHEET
//   // ============================================================

//   void _showFilterDialog({
//     required String title,
//     required String currentValue,
//     required List<String> options,
//     required ValueChanged<String>
//         onSelected,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor:
//           Colors.transparent,
//       isScrollControlled: true,
//       builder: (sheetContext) {
//         return Container(
//           width: double.infinity,
//           decoration:
//               const BoxDecoration(
//             color: Colors.white,
//             borderRadius:
//                 BorderRadius.vertical(
//               top: Radius.circular(24),
//             ),
//           ),
//           child: SafeArea(
//             top: false,
//             child: Padding(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 18,
//                 10,
//                 18,
//                 18,
//               ),
//               child: Column(
//                 mainAxisSize:
//                     MainAxisSize.min,
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   // HANDLE
//                   Center(
//                     child: Container(
//                       width: 38,
//                       height: 4,
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(
//                           0xFFD5DDDF,
//                         ),
//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           5,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(
//                     height: 18,
//                   ),

//                   Text(
//                     'Filter by $title',
//                     style:
//                         const TextStyle(
//                       color: darkText,
//                       fontSize: 19,
//                       fontWeight:
//                           FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(
//                     height: 6,
//                   ),

//                   const Text(
//                     'Choose an option below.',
//                     style:
//                         TextStyle(
//                       color:
//                           secondaryText,
//                       fontSize: 12,
//                     ),
//                   ),

//                   const SizedBox(
//                     height: 12,
//                   ),

//                   ...options.map(
//                     (option) {
//                       final bool selected =
//                           option ==
//                               currentValue;

//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.pop(
//                             sheetContext,
//                           );

//                           onSelected(
//                             option,
//                           );
//                         },
//                         child: Container(
//                           width:
//                               double.infinity,
//                           margin:
//                               const EdgeInsets
//                                   .only(
//                             bottom: 7,
//                           ),
//                           padding:
//                               const EdgeInsets
//                                   .symmetric(
//                             horizontal: 13,
//                             vertical: 13,
//                           ),
//                           decoration:
//                               BoxDecoration(
//                             color: selected
//                                 ? const Color(
//                                     0xFFFFEEE8,
//                                   )
//                                 : const Color(
//                                     0xFFF7FAFB,
//                                   ),
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               11,
//                             ),
//                             border:
//                                 Border.all(
//                               color: selected
//                                   ? primaryColor
//                                   : const Color(
//                                       0xFFE4EAEC,
//                                     ),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   option,
//                                   style:
//                                       TextStyle(
//                                     color:
//                                         selected
//                                             ? primaryColor
//                                             : darkText,
//                                     fontSize:
//                                         13,
//                                     fontWeight:
//                                         selected
//                                             ? FontWeight.w600
//                                             : FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                               if (selected)
//                                 const Icon(
//                                   Icons
//                                       .check_circle_rounded,
//                                   color:
//                                       primaryColor,
//                                   size: 19,
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // CLEAR ALL FILTERS
//   // ============================================================

//   void _clearAllFilters() {
//     setState(() {
//       selectedCategory = 'All';
//       selectedBreed = 'All Breeds';
//       selectedAge = 'Any Age';
//       selectedGender = 'Any Gender';
//       selectedStatus = 'All Status';
//       _searchController.clear();
//     });
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style:
//               const TextStyle(
//             fontSize: 12,
//           ),
//         ),
//         behavior:
//             SnackBarBehavior.floating,
//         duration:
//             const Duration(
//           seconds: 2,
//         ),
//         margin:
//             const EdgeInsets.fromLTRB(
//           16,
//           0,
//           16,
//           16,
//         ),
//         shape:
//             RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
// }

// // ============================================================================
// // CUSTOM PAW PRINT
// // ============================================================================
// //
// // This creates the paw-print design based on the image you provided.
// //
// // It contains:
// //   • 4 toe pads
// //   • 1 large center paw pad
// //
// // It is NOT Flutter's default Icons.pets.
// //
// // ============================================================================

// class PawPrintPainter extends CustomPainter {
//   final Color pawColor;

//   PawPrintPainter({
//     required this.pawColor,
//   });

//   @override
//   void paint(
//     Canvas canvas,
//     Size size,
//   ) {
//     final Paint paint = Paint()
//       ..color = pawColor
//       ..style = PaintingStyle.fill;

//     final double w = size.width;
//     final double h = size.height;

//     // ==========================================================
//     // CENTER PAW PAD
//     // ==========================================================

//     final Path centerPad = Path();

//     centerPad.moveTo(
//       w * 0.50,
//       h * 0.46,
//     );

//     centerPad.cubicTo(
//       w * 0.31,
//       h * 0.45,
//       w * 0.22,
//       h * 0.60,
//       w * 0.24,
//       h * 0.74,
//     );

//     centerPad.cubicTo(
//       w * 0.26,
//       h * 0.86,
//       w * 0.37,
//       h * 0.92,
//       w * 0.46,
//       h * 0.84,
//     );

//     centerPad.cubicTo(
//       w * 0.50,
//       h * 0.81,
//       w * 0.54,
//       h * 0.81,
//       w * 0.58,
//       h * 0.84,
//     );

//     centerPad.cubicTo(
//       w * 0.67,
//       h * 0.92,
//       w * 0.78,
//       h * 0.86,
//       w * 0.80,
//       h * 0.74,
//     );

//     centerPad.cubicTo(
//       w * 0.82,
//       h * 0.60,
//       w * 0.69,
//       h * 0.45,
//       w * 0.50,
//       h * 0.46,
//     );

//     centerPad.close();

//     canvas.drawPath(
//       centerPad,
//       paint,
//     );

//     // ==========================================================
//     // LEFT OUTER TOE
//     // ==========================================================

//     canvas.drawOval(
//       Rect.fromCenter(
//         center: Offset(
//           w * 0.20,
//           h * 0.37,
//         ),
//         width: w * 0.25,
//         height: h * 0.36,
//       ),
//       paint,
//     );

//     // ==========================================================
//     // LEFT INNER TOE
//     // ==========================================================

//     canvas.drawOval(
//       Rect.fromCenter(
//         center: Offset(
//           w * 0.37,
//           h * 0.21,
//         ),
//         width: w * 0.25,
//         height: h * 0.34,
//       ),
//       paint,
//     );

//     // ==========================================================
//     // RIGHT INNER TOE
//     // ==========================================================

//     canvas.drawOval(
//       Rect.fromCenter(
//         center: Offset(
//           w * 0.63,
//           h * 0.21,
//         ),
//         width: w * 0.25,
//         height: h * 0.34,
//       ),
//       paint,
//     );

//     // ==========================================================
//     // RIGHT OUTER TOE
//     // ==========================================================

//     canvas.drawOval(
//       Rect.fromCenter(
//         center: Offset(
//           w * 0.80,
//           h * 0.37,
//         ),
//         width: w * 0.25,
//         height: h * 0.36,
//       ),
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(
//     covariant PawPrintPainter oldDelegate,
//   ) {
//     return oldDelegate.pawColor !=
//         pawColor;
//   }
// }






























import 'package:flutter/material.dart';

import 'pet_details_screen.dart';

class PetsScreen extends StatefulWidget {
  final String initialCategory;
  final bool autoFocusSearch;

  const PetsScreen({
    super.key,
    this.initialCategory = 'All',
    this.autoFocusSearch = false,
  });

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor = Color(0xFFA94327);
  static const Color backgroundColor = Color(0xFFF5FAFD);
  static const Color darkText = Color(0xFF062B35);

  static const Color tealColor = Color(0xFF008F82);
  static const Color pendingColor = Color(0xFFB65C32);

  static const Color lightBlue = Color(0xFFE7F5FA);
  static const Color borderColor = Color(0xFFD8E2E5);
  static const Color secondaryText = Color(0xFF697578);

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  // ============================================================
  // CATEGORY
  // ============================================================

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Dogs',
    'Cats',
  ];

  // ============================================================
  // EXTRA FILTERS
  // ============================================================

  String selectedBreed = 'All Breeds';
  String selectedAge = 'Any Age';
  String selectedGender = 'Any Gender';
  String selectedStatus = 'All Status';

  // ============================================================
  // FAVORITES / LIKES
  // ============================================================

  final Set<String> _likedPets = {};

  // ============================================================
  // PET DATA
  // ============================================================

  final List<Map<String, dynamic>> pets = [
    {
      'name': 'Bella',
      'breed': 'Golden Retriever',
      'age': '2 yrs',
      'gender': 'Female',
      'status': 'Available',
      'vaccinated': true,
      'kidFriendly': true,
      'energy': 'Good w/ Kids',

      // NEW
      'behavior': 'Active',
      'personalityShort': 'Friendly',
      'likes': 12,

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
      'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
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

      // NEW
      'behavior': 'Calm',
      'personalityShort': 'Shy',
      'likes': 8,

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
      'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
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

      // NEW
      'behavior': 'High Energy',
      'personalityShort': 'Playful',
      'likes': 15,

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
      'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
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

      // NEW
      'behavior': 'Quiet',
      'personalityShort': 'Affectionate',
      'likes': 10,

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
      'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
      'shelterPhone': 'Contact Shelter',
    },
  ];

  // ============================================================
// LIFECYCLE
// ============================================================

@override
void initState() {
  super.initState();

  // Get the category sent from HomeScreen
  selectedCategory = widget.initialCategory;

  // Automatically focus the search bar when requested
  if (widget.autoFocusSearch) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }
}

@override
void dispose() {
  _searchController.dispose();
  _searchFocusNode.dispose();
  super.dispose();
}

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      14,
                      16,
                      28,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildPageTitle(),

                          const SizedBox(height: 14),

                          _buildSearchBar(),

                          const SizedBox(height: 12),

                          _buildCategoryFilter(),

                          const SizedBox(height: 14),

                          _buildFilterButtons(),

                          const SizedBox(height: 18),

                          _buildResultsLabel(),

                          const SizedBox(height: 10),

                          _buildPetList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE TITLE
  // ============================================================

  Widget _buildPageTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find Your Future Pet',
          style: TextStyle(
            color: darkText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            height: 1.15,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Meet pets looking for a loving home.',
          style: TextStyle(
            color: secondaryText,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8EA),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // PROFILE
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD9E1E4),
                width: 1,
              ),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // APP NAME
          const Expanded(
            child: Text(
              'My Future Pet',
              style: TextStyle(
                color: primaryColor,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // NOTIFICATION
          _buildHeaderButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {
              _showMessage(
                'No new notifications.',
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER BUTTON
  // ============================================================

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: darkText,
            size: 22,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFE1E8EA),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) {
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: darkText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          hintText: 'Search by name or breed',
          hintStyle: TextStyle(
            color: Color(0xFF92999B),
            fontSize: 12,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 19,
            color: Color(0xFF7C8588),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 45,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY FILTER
  // ============================================================

  Widget _buildCategoryFilter() {
    return Row(
      children: categories.map((category) {
        final bool selected =
            selectedCategory == category;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration:
                    const Duration(milliseconds: 180),
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? primaryColor
                      : lightBlue,
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : darkText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // FILTER BUTTONS
  // ============================================================

  Widget _buildFilterButtons() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics:
            const BouncingScrollPhysics(),
        children: [
          _buildSmallFilter(
            label: selectedBreed == 'All Breeds'
                ? 'Breed'
                : selectedBreed,
            active:
                selectedBreed != 'All Breeds',
            onTap: () {
              _showFilterDialog(
                title: 'Breed',
                currentValue: selectedBreed,
                options: const [
                  'All Breeds',
                  'Golden Retriever',
                  'Domestic Longhair',
                  'Terrier Mix',
                  'Calico',
                ],
                onSelected: (value) {
                  setState(() {
                    selectedBreed = value;
                  });
                },
              );
            },
          ),

          const SizedBox(width: 7),

          _buildSmallFilter(
            label: selectedAge == 'Any Age'
                ? 'Age'
                : selectedAge,
            active:
                selectedAge != 'Any Age',
            onTap: () {
              _showFilterDialog(
                title: 'Age',
                currentValue: selectedAge,
                options: const [
                  'Any Age',
                  'Under 1 year',
                  '1 - 3 years',
                  '4+ years',
                ],
                onSelected: (value) {
                  setState(() {
                    selectedAge = value;
                  });
                },
              );
            },
          ),

          const SizedBox(width: 7),

          _buildSmallFilter(
            label: selectedGender == 'Any Gender'
                ? 'Gender'
                : selectedGender,
            active:
                selectedGender != 'Any Gender',
            onTap: () {
              _showFilterDialog(
                title: 'Gender',
                currentValue: selectedGender,
                options: const [
                  'Any Gender',
                  'Male',
                  'Female',
                ],
                onSelected: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              );
            },
          ),

          const SizedBox(width: 7),

          _buildSmallFilter(
            label: selectedStatus == 'All Status'
                ? 'Status'
                : selectedStatus,
            active:
                selectedStatus != 'All Status',
            onTap: () {
              _showFilterDialog(
                title: 'Status',
                currentValue: selectedStatus,
                options: const [
                  'All Status',
                  'Available',
                  'Pending',
                ],
                onSelected: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              );
            },
          ),

          const SizedBox(width: 7),

          _buildClearFilterButton(),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL FILTER
  // ============================================================

  Widget _buildSmallFilter({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
        ),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFFFEEE8)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? primaryColor
                : borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active
                    ? primaryColor
                    : darkText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: active
                  ? primaryColor
                  : secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLEAR FILTER BUTTON
  // ============================================================

  Widget _buildClearFilterButton() {
    final bool hasFilter =
        selectedBreed != 'All Breeds' ||
        selectedAge != 'Any Age' ||
        selectedGender != 'Any Gender' ||
        selectedStatus != 'All Status';

    if (!hasFilter) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBreed = 'All Breeds';
          selectedAge = 'Any Age';
          selectedGender = 'Any Gender';
          selectedStatus = 'All Status';
        });
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3F4),
          borderRadius:
              BorderRadius.circular(10),
        ),
        child: const Text(
          'Clear',
          style: TextStyle(
            color: secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESULTS LABEL
  // ============================================================

  Widget _buildResultsLabel() {
    final List<Map<String, dynamic>> filtered =
        _getFilteredPets();

    return Row(
      children: [
        Text(
          '${filtered.length} ${filtered.length == 1 ? 'pet' : 'pets'} found',
          style: const TextStyle(
            color: darkText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        const Icon(
          Icons.tune_rounded,
          size: 15,
          color: secondaryText,
        ),
      ],
    );
  }

  // ============================================================
  // FILTERED PETS
  // ============================================================

  List<Map<String, dynamic>> _getFilteredPets() {
    final String searchText =
        _searchController.text
            .trim()
            .toLowerCase();

    return pets.where((pet) {
      final bool categoryMatch =
          selectedCategory == 'All' ||
              pet['category'] ==
                  selectedCategory;

      final bool searchMatch =
          searchText.isEmpty ||
              pet['name']
                  .toString()
                  .toLowerCase()
                  .contains(searchText) ||
              pet['breed']
                  .toString()
                  .toLowerCase()
                  .contains(searchText);

      final bool breedMatch =
          selectedBreed == 'All Breeds' ||
              pet['breed'] ==
                  selectedBreed;

      final bool ageMatch =
          _matchesAge(
        pet['age'].toString(),
      );

      final bool genderMatch =
          selectedGender == 'Any Gender' ||
              pet['gender'] ==
                  selectedGender;

      final bool statusMatch =
          selectedStatus == 'All Status' ||
              pet['status'] ==
                  selectedStatus;

      return categoryMatch &&
          searchMatch &&
          breedMatch &&
          ageMatch &&
          genderMatch &&
          statusMatch;
    }).toList();
  }

  // ============================================================
  // AGE MATCH
  // ============================================================

  bool _matchesAge(String age) {
    if (selectedAge == 'Any Age') {
      return true;
    }

    final String numberOnly =
        age.replaceAll(
      RegExp(r'[^0-9.]'),
      '',
    );

    final double petAge =
        double.tryParse(numberOnly) ?? 0;

    switch (selectedAge) {
      case 'Under 1 year':
        return petAge < 1;

      case '1 - 3 years':
        return petAge >= 1 &&
            petAge <= 3;

      case '4+ years':
        return petAge >= 4;

      default:
        return true;
    }
  }

  // ============================================================
  // PET LIST
  // ============================================================

  Widget _buildPetList() {
    final List<Map<String, dynamic>> filteredPets =
        _getFilteredPets();

    if (filteredPets.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: filteredPets.map((pet) {
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 16,
          ),
          child: _buildPetCard(pet),
        );
      }).toList(),
    );
  }

  // ============================================================
  // PET CARD
  // ============================================================

  Widget _buildPetCard(
    Map<String, dynamic> pet,
  ) {
    final bool isAvailable =
        pet['status'] == 'Available';

    final String petName =
        pet['name'].toString();

    final bool isLiked =
        _likedPets.contains(petName);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PetDetailsScreen(
              pet: pet,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFDCE7EA),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(
                0.035,
              ),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            AspectRatio(
              aspectRatio: 1.35,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    pet['image'].toString(),
                    fit: BoxFit.cover,
                    alignment:
                        Alignment.center,
                    errorBuilder:
                        (_, __, ___) {
                      return Container(
                        color:
                            const Color(
                          0xFFE9EEF0,
                        ),
                        child: Icon(
                          pet['category'] ==
                                  'Dogs'
                              ? Icons.pets
                              : Icons
                                  .cruelty_free,
                          color:
                              primaryColor,
                          size: 52,
                        ),
                      );
                    },
                  ),

                  // ==================================================
                  // GRADIENT
                  // ==================================================

                  Positioned.fill(
                    child: DecoratedBox(
                      decoration:
                          BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin: Alignment
                              .topCenter,
                          end: Alignment
                              .bottomCenter,
                          stops: const [
                            0.35,
                            1.0,
                          ],
                          colors: [
                            Colors
                                .transparent,
                            Colors.black
                                .withOpacity(
                              0.78,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // STATUS
                  // ==================================================

                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: isAvailable
                            ? tealColor
                            : pendingColor,
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                      ),
                      child: Text(
                        pet['status']
                            .toString()
                            .toUpperCase(),
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 8,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing:
                              0.3,
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // FAVORITE / LIKE BUTTON
                  // ==================================================

                  Positioned(
                    right: 11,
                    bottom: 12,
                    child: Material(
                      color:
                          Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            final int currentLikes =
                                int.tryParse(
                                      pet['likes']
                                          .toString(),
                                    ) ??
                                    0;

                            if (isLiked) {
                              _likedPets
                                  .remove(
                                petName,
                              );

                              pet['likes'] =
                                  currentLikes >
                                          0
                                      ? currentLikes -
                                          1
                                      : 0;
                            } else {
                              _likedPets.add(
                                petName,
                              );

                              pet['likes'] =
                                  currentLikes +
                                      1;
                            }
                          });
                        },
                        borderRadius:
                            BorderRadius
                                .circular(
                          50,
                        ),
                        child: Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.white
                                .withOpacity(
                              0.93,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                isLiked
                                    ? Icons
                                        .favorite_rounded
                                    : Icons
                                        .favorite_border_rounded,
                                size: 18,
                                color: isLiked
                                    ? primaryColor
                                    : const Color(
                                        0xFF667477,
                                      ),
                              ),

                              const SizedBox(
                                width: 4,
                              ),

                              Text(
                                '${pet['likes'] ?? 0}',
                                style:
                                    const TextStyle(
                                  color: Color(
                                    0xFF45575B,
                                  ),
                                  fontSize: 10,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==================================================
                  // PET INFORMATION
                  // ==================================================

                  Positioned(
                    left: 14,
                    right: 90,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        // PET NAME
                        Text(
                          pet['name']
                              .toString(),
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        // BREED + AGE
                        Text(
                          '${pet['breed']} • ${pet['age']}',
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w400,
                          ),
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        // ==================================================
                        // BEHAVIOR + PERSONALITY
                        // ==================================================

                        Row(
                          children: [
                            // BEHAVIOR
                            Flexible(
                              child:
                                  Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                    0.18,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                  border:
                                      Border.all(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                      0.30,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min,
                                  children: [
                                    const Icon(
                                      Icons
                                          .bolt_rounded,
                                      color:
                                          Colors.white,
                                      size: 11,
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Flexible(
                                      child:
                                          Text(
                                        pet['behavior']
                                                ?.toString() ??
                                            'Active',
                                        maxLines:
                                            1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              8,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            // PERSONALITY
                            Flexible(
                              child:
                                  Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 7,
                                  vertical: 4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                    0.18,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                  border:
                                      Border.all(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                      0.30,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize
                                          .min,
                                  children: [
                                    const Icon(
                                      Icons
                                          .favorite_border_rounded,
                                      color:
                                          Colors.white,
                                      size: 10,
                                    ),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Flexible(
                                      child:
                                          Text(
                                        pet['personalityShort']
                                                ?.toString() ??
                                            'Friendly',
                                        maxLines:
                                            1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              8,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // TAGS
            // ==================================================

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(
                11,
                9,
                11,
                10,
              ),
              child: SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                physics:
                    const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    if (pet['vaccinated'] ==
                        true)
                      _buildPetTag(
                        icon: Icons
                            .vaccines_rounded,
                        text: 'Vaccinated',
                      ),

                    if (pet['vaccinated'] ==
                            true &&
                        (pet['kidFriendly'] ==
                                true ||
                            pet['energy'] !=
                                null))
                      const SizedBox(
                        width: 6,
                      ),

                    if (pet['kidFriendly'] ==
                        true)
                      _buildPetTag(
                        icon: Icons
                            .child_friendly_rounded,
                        text: 'Good w/ Kids',
                      ),

                    if (pet['kidFriendly'] ==
                            true &&
                        pet['energy'] !=
                            null)
                      const SizedBox(
                        width: 6,
                      ),

                    if (pet['energy'] !=
                        null)
                      _buildPetTag(
                        icon:
                            Icons.bolt_rounded,
                        text:
                            pet['energy']
                                .toString(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PET TAG
  // ============================================================

  Widget _buildPetTag({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFFE9F7F6),
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: tealColor,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style:
                const TextStyle(
              color:
                  Color(0xFF34706C),
              fontSize: 8,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 55,
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration:
                const BoxDecoration(
              color: Color(0xFFE7F5FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No pets found',
            style: TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Try another search or change your filters.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: secondaryText,
              fontSize: 12,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          OutlinedButton(
            onPressed:
                _clearAllFilters,
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  primaryColor,
              side:
                  const BorderSide(
                color: primaryColor,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 18,
                vertical: 10,
              ),
            ),
            child: const Text(
              'Clear Filters',
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER BOTTOM SHEET
  // ============================================================

  void _showFilterDialog({
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String>
        onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          width: double.infinity,
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                18,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // HANDLE
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFD5DDDF,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  Text(
                    'Filter by $title',
                    style:
                        const TextStyle(
                      color: darkText,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  const Text(
                    'Choose an option below.',
                    style:
                        TextStyle(
                      color:
                          secondaryText,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  ...options.map(
                    (option) {
                      final bool selected =
                          option ==
                              currentValue;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(
                            sheetContext,
                          );

                          onSelected(
                            option,
                          );
                        },
                        child: Container(
                          width:
                              double.infinity,
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 7,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 13,
                            vertical: 13,
                          ),
                          decoration:
                              BoxDecoration(
                            color: selected
                                ? const Color(
                                    0xFFFFEEE8,
                                  )
                                : const Color(
                                    0xFFF7FAFB,
                                  ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              11,
                            ),
                            border:
                                Border.all(
                              color: selected
                                  ? primaryColor
                                  : const Color(
                                      0xFFE4EAEC,
                                    ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style:
                                      TextStyle(
                                    color:
                                        selected
                                            ? primaryColor
                                            : darkText,
                                    fontSize:
                                        13,
                                    fontWeight:
                                        selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                  ),
                                ),
                              ),

                              if (selected)
                                const Icon(
                                  Icons
                                      .check_circle_rounded,
                                  color:
                                      primaryColor,
                                  size: 19,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // CLEAR ALL FILTERS
  // ============================================================

  void _clearAllFilters() {
    setState(() {
      selectedCategory = 'All';
      selectedBreed = 'All Breeds';
      selectedAge = 'Any Age';
      selectedGender = 'Any Gender';
      selectedStatus = 'All Status';
      _searchController.clear();
    });
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(
            fontSize: 12,
          ),
        ),
        behavior:
            SnackBarBehavior.floating,
        duration:
            const Duration(
          seconds: 2,
        ),
        margin:
            const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    );
  }
}

































// import 'package:flutter/material.dart';

// import '../pet_data.dart';
// import 'pet_details_screen.dart';

// class PetsScreen extends StatefulWidget {
//   final String initialCategory;
//   final bool autoFocusSearch;

//   const PetsScreen({
//     super.key,
//     this.initialCategory = 'All',
//     this.autoFocusSearch = false,
//   });

//   @override
//   State<PetsScreen> createState() =>
//       _PetsScreenState();
// }

// class _PetsScreenState extends State<PetsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor =
//       Color(0xFFA94327);

//   static const Color backgroundColor =
//       Color(0xFFF5FAFD);

//   static const Color darkText =
//       Color(0xFF062B35);

//   static const Color tealColor =
//       Color(0xFF008F82);

//   static const Color pendingColor =
//       Color(0xFFB65C32);

//   static const Color lightBlue =
//       Color(0xFFE7F5FA);

//   static const Color borderColor =
//       Color(0xFFD8E2E5);

//   static const Color secondaryText =
//       Color(0xFF697578);

//   // ============================================================
//   // SEARCH
//   // ============================================================

//   final TextEditingController
//       _searchController =
//       TextEditingController();

//   final FocusNode _searchFocusNode =
//       FocusNode();

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Dogs',
//     'Cats',
//   ];

//   // ============================================================
//   // EXTRA FILTERS
//   // ============================================================

//   String selectedBreed = 'All Breeds';
//   String selectedAge = 'Any Age';
//   String selectedGender = 'Any Gender';
//   String selectedStatus = 'All Status';

//   // ============================================================
//   // SHARED PET DATA
//   // ============================================================

//   List<Map<String, dynamic>> get pets =>
//       PetData.pets;

//   // ============================================================
//   // INIT
//   // ============================================================

//   @override
//   void initState() {
//     super.initState();

//     selectedCategory =
//         widget.initialCategory;

//     if (widget.autoFocusSearch) {
//       WidgetsBinding.instance
//           .addPostFrameCallback((_) {
//         if (mounted) {
//           _searchFocusNode.requestFocus();
//         }
//       });
//     }
//   }

//   // ============================================================
//   // DISPOSE
//   // ============================================================

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           backgroundColor,

//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             _buildHeader(),

//             Expanded(
//               child: LayoutBuilder(
//                 builder:
//                     (context, constraints) {
//                   return SingleChildScrollView(
//                     physics:
//                         const BouncingScrollPhysics(),
//                     padding:
//                         const EdgeInsets.fromLTRB(
//                       16,
//                       14,
//                       16,
//                       28,
//                     ),
//                     child: ConstrainedBox(
//                       constraints:
//                           BoxConstraints(
//                         minHeight:
//                             constraints
//                                 .maxHeight,
//                       ),
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment
//                                 .start,
//                         children: [
//                           _buildPageTitle(),

//                           const SizedBox(
//                               height: 14),

//                           _buildSearchBar(),

//                           const SizedBox(
//                               height: 12),

//                           _buildCategoryFilter(),

//                           const SizedBox(
//                               height: 14),

//                           _buildFilterButtons(),

//                           const SizedBox(
//                               height: 18),

//                           _buildResultsLabel(),

//                           const SizedBox(
//                               height: 10),

//                           _buildPetList(),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       height: 58,
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 16,
//       ),
//       decoration:
//           const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE2E8EA),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 34,
//             height: 34,
//             decoration:
//                 BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color:
//                     const Color(0xFFD9E1E4),
//               ),
//               image:
//                   const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           const Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 19,
//                 fontWeight:
//                     FontWeight.bold,
//               ),
//             ),
//           ),

//           IconButton(
//             onPressed: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//             icon: const Icon(
//               Icons
//                   .notifications_none_rounded,
//               color: darkText,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PAGE TITLE
//   // ============================================================

//   Widget _buildPageTitle() {
//     return const Column(
//       crossAxisAlignment:
//           CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Find Your Future Pet',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 22,
//             fontWeight:
//                 FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           'Meet pets looking for a loving home.',
//           style: TextStyle(
//             color: secondaryText,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _buildSearchBar() {
//     return Container(
//       width: double.infinity,
//       height: 48,
//       decoration:
//           BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(25),
//         border: Border.all(
//           color:
//               const Color(0xFFE1E8EA),
//         ),
//       ),
//       child: TextField(
//         controller:
//             _searchController,
//         focusNode:
//             _searchFocusNode,
//         onChanged: (_) {
//           setState(() {});
//         },
//         textInputAction:
//             TextInputAction.search,
//         decoration:
//             const InputDecoration(
//           hintText:
//               'Search by name or breed',
//           hintStyle: TextStyle(
//             color:
//                 Color(0xFF92999B),
//             fontSize: 12,
//           ),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             size: 19,
//             color:
//                 Color(0xFF7C8588),
//           ),
//           border:
//               InputBorder.none,
//           contentPadding:
//               EdgeInsets.symmetric(
//             vertical: 14,
//             horizontal: 8,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   Widget _buildCategoryFilter() {
//     return Row(
//       children:
//           categories.map((category) {
//         final bool selected =
//             selectedCategory ==
//                 category;

//         return Expanded(
//           child: Padding(
//             padding:
//                 const EdgeInsets
//                     .symmetric(
//               horizontal: 3,
//             ),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory =
//                       category;
//                 });
//               },
//               child:
//                   AnimatedContainer(
//                 duration:
//                     const Duration(
//                   milliseconds: 180,
//                 ),
//                 height: 42,
//                 decoration:
//                     BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : lightBlue,
//                   borderRadius:
//                       BorderRadius
//                           .circular(22),
//                 ),
//                 alignment:
//                     Alignment.center,
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 12,
//                     fontWeight:
//                         FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // FILTER BUTTONS
//   // ============================================================

//   Widget _buildFilterButtons() {
//     return SizedBox(
//       height: 38,
//       child: ListView(
//         scrollDirection:
//             Axis.horizontal,
//         children: [
//           _buildSmallFilter(
//             label:
//                 selectedBreed ==
//                         'All Breeds'
//                     ? 'Breed'
//                     : selectedBreed,
//             active:
//                 selectedBreed !=
//                     'All Breeds',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Breed',
//                 currentValue:
//                     selectedBreed,
//                 options: const [
//                   'All Breeds',
//                   'Golden Retriever',
//                   'Domestic Longhair',
//                   'Terrier Mix',
//                   'Calico',
//                 ],
//                 onSelected:
//                     (value) {
//                   setState(() {
//                     selectedBreed =
//                         value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildSmallFilter(
//             label:
//                 selectedAge ==
//                         'Any Age'
//                     ? 'Age'
//                     : selectedAge,
//             active:
//                 selectedAge !=
//                     'Any Age',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Age',
//                 currentValue:
//                     selectedAge,
//                 options: const [
//                   'Any Age',
//                   'Under 1 year',
//                   '1 - 3 years',
//                   '4+ years',
//                 ],
//                 onSelected:
//                     (value) {
//                   setState(() {
//                     selectedAge =
//                         value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildSmallFilter(
//             label:
//                 selectedGender ==
//                         'Any Gender'
//                     ? 'Gender'
//                     : selectedGender,
//             active:
//                 selectedGender !=
//                     'Any Gender',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Gender',
//                 currentValue:
//                     selectedGender,
//                 options: const [
//                   'Any Gender',
//                   'Male',
//                   'Female',
//                 ],
//                 onSelected:
//                     (value) {
//                   setState(() {
//                     selectedGender =
//                         value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildSmallFilter(
//             label:
//                 selectedStatus ==
//                         'All Status'
//                     ? 'Status'
//                     : selectedStatus,
//             active:
//                 selectedStatus !=
//                     'All Status',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Status',
//                 currentValue:
//                     selectedStatus,
//                 options: const [
//                   'All Status',
//                   'Available',
//                   'Pending',
//                 ],
//                 onSelected:
//                     (value) {
//                   setState(() {
//                     selectedStatus =
//                         value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildClearButton(),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SMALL FILTER
//   // ============================================================

//   Widget _buildSmallFilter({
//     required String label,
//     required bool active,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 38,
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 13,
//         ),
//         decoration:
//             BoxDecoration(
//           color: active
//               ? const Color(
//                   0xFFFFEEE8,
//                 )
//               : Colors.white,
//           borderRadius:
//               BorderRadius.circular(10),
//           border: Border.all(
//             color: active
//                 ? primaryColor
//                 : borderColor,
//           ),
//         ),
//         child: Row(
//           mainAxisSize:
//               MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: active
//                     ? primaryColor
//                     : darkText,
//                 fontSize: 11,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//             const SizedBox(
//                 width: 3),
//             Icon(
//               Icons
//                   .keyboard_arrow_down_rounded,
//               size: 15,
//               color: active
//                   ? primaryColor
//                   : secondaryText,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CLEAR
//   // ============================================================

//   Widget _buildClearButton() {
//     final bool hasFilter =
//         selectedBreed !=
//                 'All Breeds' ||
//             selectedAge != 'Any Age' ||
//             selectedGender !=
//                 'Any Gender' ||
//             selectedStatus !=
//                 'All Status';

//     if (!hasFilter) {
//       return const SizedBox.shrink();
//     }

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedBreed =
//               'All Breeds';
//           selectedAge =
//               'Any Age';
//           selectedGender =
//               'Any Gender';
//           selectedStatus =
//               'All Status';
//         });
//       },
//       child: Container(
//         height: 38,
//         padding:
//             const EdgeInsets.symmetric(
//           horizontal: 12,
//         ),
//         alignment: Alignment.center,
//         decoration:
//             BoxDecoration(
//           color:
//               const Color(0xFFEFF3F4),
//           borderRadius:
//               BorderRadius.circular(10),
//         ),
//         child: const Text(
//           'Clear',
//           style: TextStyle(
//             color: secondaryText,
//             fontSize: 11,
//             fontWeight:
//                 FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RESULTS
//   // ============================================================

//   Widget _buildResultsLabel() {
//     final filtered =
//         _getFilteredPets();

//     return Text(
//       '${filtered.length} ${filtered.length == 1 ? 'pet' : 'pets'} found',
//       style: const TextStyle(
//         color: darkText,
//         fontSize: 12,
//         fontWeight:
//             FontWeight.w600,
//       ),
//     );
//   }

//   // ============================================================
//   // ONE FILTER SYSTEM
//   // ============================================================

//   List<Map<String, dynamic>>
//       _getFilteredPets() {
//     final String searchText =
//         _searchController.text
//             .trim()
//             .toLowerCase();

//     return pets.where((pet) {
//       final bool categoryMatch =
//           selectedCategory == 'All' ||
//               pet['category'] ==
//                   selectedCategory;

//       final bool searchMatch =
//           searchText.isEmpty ||
//               pet['name']
//                   .toString()
//                   .toLowerCase()
//                   .contains(
//                     searchText,
//                   ) ||
//               pet['breed']
//                   .toString()
//                   .toLowerCase()
//                   .contains(
//                     searchText,
//                   );

//       final bool breedMatch =
//           selectedBreed ==
//                   'All Breeds' ||
//               pet['breed'] ==
//                   selectedBreed;

//       final bool ageMatch =
//           _matchesAge(
//         pet['age'].toString(),
//       );

//       final bool genderMatch =
//           selectedGender ==
//                   'Any Gender' ||
//               pet['gender'] ==
//                   selectedGender;

//       final bool statusMatch =
//           selectedStatus ==
//                   'All Status' ||
//               pet['status'] ==
//                   selectedStatus;

//       return categoryMatch &&
//           searchMatch &&
//           breedMatch &&
//           ageMatch &&
//           genderMatch &&
//           statusMatch;
//     }).toList();
//   }

//   // ============================================================
//   // AGE FILTER
//   // ============================================================

//   bool _matchesAge(String age) {
//     if (selectedAge ==
//         'Any Age') {
//       return true;
//     }

//     final numberOnly =
//         age.replaceAll(
//       RegExp(r'[^0-9.]'),
//       '',
//     );

//     final double petAge =
//         double.tryParse(
//               numberOnly,
//             ) ??
//             0;

//     switch (selectedAge) {
//       case 'Under 1 year':
//         return petAge < 1;

//       case '1 - 3 years':
//         return petAge >= 1 &&
//             petAge <= 3;

//       case '4+ years':
//         return petAge >= 4;

//       default:
//         return true;
//     }
//   }

//   // ============================================================
//   // PET LIST
//   // ============================================================

//   Widget _buildPetList() {
//     final filtered =
//         _getFilteredPets();

//     if (filtered.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       children:
//           filtered.map((pet) {
//         return Padding(
//           padding:
//               const EdgeInsets.only(
//             bottom: 16,
//           ),
//           child:
//               _buildPetCard(pet),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // PET CARD
//   // ============================================================

//   Widget _buildPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     final bool available =
//         pet['status'] ==
//             'Available';

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) =>
//                 PetDetailsScreen(
//               pet: pet,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         decoration:
//             BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(
//             16,
//           ),
//           border: Border.all(
//             color:
//                 const Color(0xFFDCE7EA),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black
//                   .withOpacity(
//                 0.035,
//               ),
//               blurRadius: 7,
//               offset:
//                   const Offset(0, 2),
//             ),
//           ],
//         ),
//         clipBehavior:
//             Clip.antiAlias,
//         child: Column(
//           children: [
//             AspectRatio(
//               aspectRatio: 1.35,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.network(
//                     pet['image']
//                         .toString(),
//                     fit: BoxFit.cover,
//                     errorBuilder:
//                         (_, __, ___) {
//                       return Container(
//                         color:
//                             const Color(
//                           0xFFE9EEF0,
//                         ),
//                         child: Icon(
//                           pet['category'] ==
//                                   'Dogs'
//                               ? Icons.pets
//                               : Icons
//                                   .cruelty_free,
//                           color:
//                               primaryColor,
//                           size: 52,
//                         ),
//                       );
//                     },
//                   ),

//                   Positioned.fill(
//                     child:
//                         DecoratedBox(
//                       decoration:
//                           BoxDecoration(
//                         gradient:
//                             LinearGradient(
//                           begin:
//                               Alignment
//                                   .topCenter,
//                           end:
//                               Alignment
//                                   .bottomCenter,
//                           colors: [
//                             Colors
//                                 .transparent,
//                             Colors.black
//                                 .withOpacity(
//                               0.75,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 10,
//                         vertical: 6,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color: available
//                             ? tealColor
//                             : pendingColor,
//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           18,
//                         ),
//                       ),
//                       child: Text(
//                         pet['status']
//                             .toString()
//                             .toUpperCase(),
//                         style:
//                             const TextStyle(
//                           color:
//                               Colors.white,
//                           fontSize: 8,
//                           fontWeight:
//                               FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   Positioned(
//                     left: 14,
//                     right: 14,
//                     bottom: 14,
//                     child: Row(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .end,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment
//                                     .start,
//                             children: [
//                               Text(
//                                 pet['name']
//                                     .toString(),
//                                 style:
//                                     const TextStyle(
//                                   color:
//                                       Colors.white,
//                                   fontSize:
//                                       20,
//                                   fontWeight:
//                                       FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(
//                                   height: 3),
//                               Text(
//                                 '${pet['breed']} • ${pet['age']}',
//                                 style:
//                                     const TextStyle(
//                                   color:
//                                       Colors.white,
//                                   fontSize:
//                                       10,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Container(
//                           padding:
//                               const EdgeInsets
//                                   .symmetric(
//                             horizontal: 8,
//                             vertical: 5,
//                           ),
//                           decoration:
//                               BoxDecoration(
//                             color: Colors.white
//                                 .withOpacity(
//                               0.88,
//                             ),
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               12,
//                             ),
//                           ),
//                           child: Text(
//                             pet['category']
//                                 .toString(),
//                             style:
//                                 const TextStyle(
//                               color:
//                                   darkText,
//                               fontSize: 8,
//                               fontWeight:
//                                   FontWeight
//                                       .w700,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Padding(
//               padding:
//                   const EdgeInsets.all(13),
//               child: Row(
//                 children: [
//                   _infoItem(
//                     Icons.cake_outlined,
//                     pet['age']
//                         .toString(),
//                   ),
//                   const SizedBox(
//                       width: 14),
//                   _infoItem(
//                     pet['gender'] ==
//                             'Male'
//                         ? Icons.male
//                         : Icons.female,
//                     pet['gender']
//                         .toString(),
//                   ),
//                   const SizedBox(
//                       width: 14),
//                   _infoItem(
//                     Icons
//                         .vaccines_outlined,
//                     pet['vaccinated'] ==
//                             true
//                         ? 'Vaccinated'
//                         : 'Not vaccinated',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // INFO ITEM
//   // ============================================================

//   Widget _infoItem(
//     IconData icon,
//     String text,
//   ) {
//     return Expanded(
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             size: 15,
//             color: tealColor,
//           ),
//           const SizedBox(
//               width: 4),
//           Expanded(
//             child: Text(
//               text,
//               overflow:
//                   TextOverflow.ellipsis,
//               style:
//                   const TextStyle(
//                 color:
//                     secondaryText,
//                 fontSize: 9,
//                 fontWeight:
//                     FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       padding:
//           const EdgeInsets.symmetric(
//         vertical: 45,
//         horizontal: 20,
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 65,
//             height: 65,
//             decoration:
//                 const BoxDecoration(
//               color: lightBlue,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.search_off_rounded,
//               color: primaryColor,
//               size: 32,
//             ),
//           ),
//           const SizedBox(height: 14),
//           const Text(
//             'No pets found',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 16,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             'Try another name, breed, category, or filter.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: secondaryText,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // FILTER DIALOG
//   // ============================================================

//   void _showFilterDialog({
//     required String title,
//     required String currentValue,
//     required List<String> options,
//     required ValueChanged<String>
//         onSelected,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape:
//           const RoundedRectangleBorder(
//         borderRadius:
//             BorderRadius.vertical(
//           top: Radius.circular(22),
//         ),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding:
//                 const EdgeInsets.fromLTRB(
//               20,
//               18,
//               20,
//               20,
//             ),
//             child: Column(
//               mainAxisSize:
//                   MainAxisSize.min,
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style:
//                       const TextStyle(
//                     color: darkText,
//                     fontSize: 18,
//                     fontWeight:
//                         FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(
//                     height: 10),
//                 ...options.map(
//                   (option) {
//                     final selected =
//                         option ==
//                             currentValue;

//                     return ListTile(
//                       contentPadding:
//                           EdgeInsets.zero,
//                       title: Text(
//                         option,
//                         style:
//                             TextStyle(
//                           color:
//                               darkText,
//                           fontSize:
//                               13,
//                           fontWeight:
//                               selected
//                                   ? FontWeight
//                                       .w700
//                                   : FontWeight
//                                       .normal,
//                         ),
//                       ),
//                       trailing:
//                           selected
//                               ? const Icon(
//                                   Icons
//                                       .check_circle,
//                                   color:
//                                       primaryColor,
//                                 )
//                               : null,
//                       onTap: () {
//                         onSelected(
//                             option);
//                         Navigator.pop(
//                             context);
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(
//       String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//       ),
//     );
//   }
// }






























// import 'package:flutter/material.dart';

// import 'pet_details_screen.dart';

// // class PetsScreen extends StatefulWidget {
// //   const PetsScreen({super.key});

// //   @override
// //   State<PetsScreen> createState() => _PetsScreenState();
// // }

// class PetsScreen extends StatefulWidget {
//   final String initialCategory;

//   const PetsScreen({
//     super.key,
//     this.initialCategory = 'All',
//   });

//   @override
//   State<PetsScreen> createState() =>
//       _PetsScreenState();
// }

// class _PetsScreenState extends State<PetsScreen> {

  
//   // ============================================================
//   // COLORS
//   // ============================================================

//   static const Color primaryColor = Color(0xFFA94327);
//   static const Color backgroundColor = Color(0xFFF5FAFD);
//   static const Color darkText = Color(0xFF062B35);

//   static const Color tealColor = Color(0xFF008F82);
//   static const Color pendingColor = Color(0xFFB65C32);

//   static const Color lightBlue = Color(0xFFE7F5FA);
//   static const Color borderColor = Color(0xFFD8E2E5);
//   static const Color secondaryText = Color(0xFF697578);

//   // ============================================================
//   // SEARCH
//   // ============================================================

//   final TextEditingController _searchController =
//       TextEditingController();

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   // String selectedCategory = 'All';

//   // final List<String> categories = [
//   //   'All',
//   //   'Dogs',
//   //   'Cats',
//   // ];

//   // ============================================================
//   // CATEGORY
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Dogs',
//     'Cats',
//   ];

//   @override
//   void initState() {
//     super.initState();

//     selectedCategory =
//         widget.initialCategory;
//   }

//   // ============================================================
//   // EXTRA FILTERS
//   // ============================================================

//   String selectedBreed = 'All Breeds';
//   String selectedAge = 'Any Age';
//   String selectedGender = 'Any Gender';
//   String selectedStatus = 'All Status';

//   // ============================================================
//   // PET DATA
//   // ============================================================

//   final List<Map<String, dynamic>> pets = [
//     {
//       'name': 'Bella',
//       'breed': 'Golden Retriever',
//       'age': '2 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': true,
//       'energy': 'Good w/ Kids',
//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=1200',
//       'category': 'Dogs',

//       'weight': '65 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Friendly',
//         'Active',
//         'Good with Kids',
//       ],
//       'about':
//           'Bella is a sweet, energetic dog who loves everyone she meets. She was brought to our shelter when her previous owners had to move overseas. She thrives on outdoor activities and would make a perfect companion for an active family. She already knows basic commands and is fully house-trained.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Domestic Longhair',
//       'age': '4 yrs',
//       'gender': 'Male',
//       'status': 'Pending',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Calm',
//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=1200',
//       'category': 'Cats',

//       'weight': '11 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Calm',
//         'Gentle',
//         'Independent',
//       ],
//       'about':
//           'Oliver is a calm and gentle cat who enjoys quiet environments and relaxing indoors. He is affectionate once he gets comfortable and would be a wonderful companion for someone looking for a peaceful pet.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Scout',
//       'breed': 'Terrier Mix',
//       'age': '1 yr',
//       'gender': 'Male',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'High Energy',
//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=1200',
//       'category': 'Dogs',

//       'weight': '22 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Playful',
//         'Active',
//         'Loyal',
//       ],
//       'about':
//           'Scout is a playful young dog full of energy. He loves exploring, playing outdoors, and spending time with people. He would be a great match for an active family who can give him plenty of exercise and attention.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Calico',
//       'age': '3 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Indoor Only',
//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=1200',
//       'category': 'Cats',

//       'weight': '9 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Gentle',
//         'Quiet',
//         'Affectionate',
//       ],
//       'about':
//           'Luna is a gentle and affectionate cat who prefers a calm indoor environment. She enjoys relaxing in cozy spaces and slowly building trust with her humans.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//   ];

//   // ============================================================
//   // LIFECYCLE
//   // ============================================================

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             _buildHeader(),

//             Expanded(
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   return SingleChildScrollView(
//                     physics:
//                         const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.fromLTRB(
//                       16,
//                       14,
//                       16,
//                       28,
//                     ),
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(
//                         minHeight: constraints.maxHeight,
//                       ),
//                       child: Column(
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         children: [
//                           _buildPageTitle(),

//                           const SizedBox(height: 14),

//                           _buildSearchBar(),

//                           const SizedBox(height: 12),

//                           _buildCategoryFilter(),

//                           const SizedBox(height: 14),

//                           _buildFilterButtons(),

//                           const SizedBox(height: 18),

//                           _buildResultsLabel(),

//                           const SizedBox(height: 10),

//                           _buildPetList(),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PAGE TITLE
//   // ============================================================

//   Widget _buildPageTitle() {
//     return const Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Find Your Future Pet',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             height: 1.15,
//           ),
//         ),
//         SizedBox(height: 4),
//         Text(
//           'Meet pets looking for a loving home.',
//           style: TextStyle(
//             color: secondaryText,
//             fontSize: 12,
//             height: 1.35,
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       width: double.infinity,
//       height: 58,
//       padding: const EdgeInsets.symmetric(
//         horizontal: 16,
//       ),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE2E8EA),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // PROFILE
//           Container(
//             width: 34,
//             height: 34,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFD9E1E4),
//                 width: 1,
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           // APP NAME
//           const Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 19,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // NOTIFICATION
//           _buildHeaderButton(
//             icon: Icons.notifications_none_rounded,
//             onTap: () {
//               _showMessage(
//                 'No new notifications.',
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER BUTTON
//   // ============================================================

//   Widget _buildHeaderButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(50),
//         child: SizedBox(
//           width: 40,
//           height: 40,
//           child: Icon(
//             icon,
//             color: darkText,
//             size: 22,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _buildSearchBar() {
//     return Container(
//       width: double.infinity,
//       height: 48,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(25),
//         border: Border.all(
//           color: const Color(0xFFE1E8EA),
//           width: 1,
//         ),
//       ),
//       child: TextField(
//         controller: _searchController,
//         onChanged: (_) {
//           setState(() {});
//         },
//         textInputAction: TextInputAction.search,
//         style: const TextStyle(
//           color: darkText,
//           fontSize: 13,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: const InputDecoration(
//           hintText: 'Search by name or breed',
//           hintStyle: TextStyle(
//             color: Color(0xFF92999B),
//             fontSize: 12,
//           ),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             size: 19,
//             color: Color(0xFF7C8588),
//           ),
//           prefixIconConstraints: BoxConstraints(
//             minWidth: 45,
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             vertical: 14,
//             horizontal: 8,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY FILTER
//   // ============================================================

//   Widget _buildCategoryFilter() {
//     return Row(
//       children: categories.map((category) {
//         final bool selected =
//             selectedCategory == category;

//         return Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 3,
//             ),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration:
//                     const Duration(milliseconds: 180),
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : lightBlue,
//                   borderRadius:
//                       BorderRadius.circular(22),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // FILTER BUTTONS
//   // ============================================================

//   Widget _buildFilterButtons() {
//     return SizedBox(
//       height: 38,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         physics:
//             const BouncingScrollPhysics(),
//         children: [
//           _buildSmallFilter(
//             label: selectedBreed == 'All Breeds'
//                 ? 'Breed'
//                 : selectedBreed,
//             active:
//                 selectedBreed != 'All Breeds',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Breed',
//                 currentValue: selectedBreed,
//                 options: const [
//                   'All Breeds',
//                   'Golden Retriever',
//                   'Domestic Longhair',
//                   'Terrier Mix',
//                   'Calico',
//                 ],
//                 onSelected: (value) {
//                   setState(() {
//                     selectedBreed = value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildSmallFilter(
//             label: selectedAge == 'Any Age'
//                 ? 'Age'
//                 : selectedAge,
//             active:
//                 selectedAge != 'Any Age',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Age',
//                 currentValue: selectedAge,
//                 options: const [
//                   'Any Age',
//                   'Under 1 year',
//                   '1 - 3 years',
//                   '4+ years',
//                 ],
//                 onSelected: (value) {
//                   setState(() {
//                     selectedAge = value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildSmallFilter(
//             label: selectedGender == 'Any Gender'
//                 ? 'Gender'
//                 : selectedGender,
//             active:
//                 selectedGender != 'Any Gender',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Gender',
//                 currentValue: selectedGender,
//                 options: const [
//                   'Any Gender',
//                   'Male',
//                   'Female',
//                 ],
//                 onSelected: (value) {
//                   setState(() {
//                     selectedGender = value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildSmallFilter(
//             label: selectedStatus == 'All Status'
//                 ? 'Status'
//                 : selectedStatus,
//             active:
//                 selectedStatus != 'All Status',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Status',
//                 currentValue: selectedStatus,
//                 options: const [
//                   'All Status',
//                   'Available',
//                   'Pending',
//                 ],
//                 onSelected: (value) {
//                   setState(() {
//                     selectedStatus = value;
//                   });
//                 },
//               );
//             },
//           ),

//           const SizedBox(width: 7),

//           _buildClearFilterButton(),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SMALL FILTER
//   // ============================================================

//   Widget _buildSmallFilter({
//     required String label,
//     required bool active,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 38,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 13,
//         ),
//         decoration: BoxDecoration(
//           color: active
//               ? const Color(0xFFFFEEE8)
//               : Colors.white,
//           borderRadius:
//               BorderRadius.circular(10),
//           border: Border.all(
//             color: active
//                 ? primaryColor
//                 : borderColor,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: active
//                     ? primaryColor
//                     : darkText,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(width: 3),
//             Icon(
//               Icons.keyboard_arrow_down_rounded,
//               size: 15,
//               color: active
//                   ? primaryColor
//                   : secondaryText,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CLEAR FILTER BUTTON
//   // ============================================================

//   Widget _buildClearFilterButton() {
//     final bool hasFilter =
//         selectedBreed != 'All Breeds' ||
//         selectedAge != 'Any Age' ||
//         selectedGender != 'Any Gender' ||
//         selectedStatus != 'All Status';

//     if (!hasFilter) {
//       return const SizedBox.shrink();
//     }

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedBreed = 'All Breeds';
//           selectedAge = 'Any Age';
//           selectedGender = 'Any Gender';
//           selectedStatus = 'All Status';
//         });
//       },
//       child: Container(
//         height: 38,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 12,
//         ),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: const Color(0xFFEFF3F4),
//           borderRadius:
//               BorderRadius.circular(10),
//         ),
//         child: const Text(
//           'Clear',
//           style: TextStyle(
//             color: secondaryText,
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // RESULTS LABEL
//   // ============================================================

//   Widget _buildResultsLabel() {
//     final List<Map<String, dynamic>> filtered =
//         _getFilteredPets();

//     return Row(
//       children: [
//         Text(
//           '${filtered.length} ${filtered.length == 1 ? 'pet' : 'pets'} found',
//           style: const TextStyle(
//             color: darkText,
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const Spacer(),
//         const Icon(
//           Icons.tune_rounded,
//           size: 15,
//           color: secondaryText,
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // FILTERED PETS
//   // ============================================================

//   List<Map<String, dynamic>> _getFilteredPets() {
//     final String searchText =
//         _searchController.text
//             .trim()
//             .toLowerCase();

//     return pets.where((pet) {
//       // CATEGORY
//       final bool categoryMatch =
//           selectedCategory == 'All' ||
//               pet['category'] ==
//                   selectedCategory;

//       // SEARCH
//       final bool searchMatch =
//           searchText.isEmpty ||
//               pet['name']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText) ||
//               pet['breed']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText);

//       // BREED
//       final bool breedMatch =
//           selectedBreed == 'All Breeds' ||
//               pet['breed'] ==
//                   selectedBreed;

//       // AGE
//       final bool ageMatch =
//           _matchesAge(pet['age'].toString());

//       // GENDER
//       final bool genderMatch =
//           selectedGender == 'Any Gender' ||
//               pet['gender'] ==
//                   selectedGender;

//       // STATUS
//       final bool statusMatch =
//           selectedStatus == 'All Status' ||
//               pet['status'] ==
//                   selectedStatus;

//       return categoryMatch &&
//           searchMatch &&
//           breedMatch &&
//           ageMatch &&
//           genderMatch &&
//           statusMatch;
//     }).toList();
//   }

//   // ============================================================
//   // AGE MATCH
//   // ============================================================

//   bool _matchesAge(String age) {
//     if (selectedAge == 'Any Age') {
//       return true;
//     }

//     final String numberOnly =
//         age.replaceAll(
//       RegExp(r'[^0-9.]'),
//       '',
//     );

//     final double petAge =
//         double.tryParse(numberOnly) ?? 0;

//     switch (selectedAge) {
//       case 'Under 1 year':
//         return petAge < 1;

//       case '1 - 3 years':
//         return petAge >= 1 &&
//             petAge <= 3;

//       case '4+ years':
//         return petAge >= 4;

//       default:
//         return true;
//     }
//   }

//   // ============================================================
//   // PET LIST
//   // ============================================================

//   Widget _buildPetList() {
//     final List<Map<String, dynamic>> filteredPets =
//         _getFilteredPets();

//     if (filteredPets.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       children: filteredPets.map((pet) {
//         return Padding(
//           padding:
//               const EdgeInsets.only(
//             bottom: 16,
//           ),
//           child: _buildPetCard(pet),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // PET CARD
//   // ============================================================

//   Widget _buildPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     final bool isAvailable =
//         pet['status'] == 'Available';

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) =>
//                 PetDetailsScreen(
//               pet: pet,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius:
//               BorderRadius.circular(16),
//           border: Border.all(
//             color: const Color(0xFFDCE7EA),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color:
//                   Colors.black.withOpacity(
//                 0.035,
//               ),
//               blurRadius: 7,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           children: [
//             // ==================================================
//             // IMAGE
//             // ==================================================

//             AspectRatio(
//               aspectRatio: 1.35,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.network(
//                     pet['image'].toString(),
//                     fit: BoxFit.cover,
//                     alignment:
//                         Alignment.center,
//                     errorBuilder:
//                         (_, __, ___) {
//                       return Container(
//                         color:
//                             const Color(
//                           0xFFE9EEF0,
//                         ),
//                         child: Icon(
//                           pet['category'] ==
//                                   'Dogs'
//                               ? Icons.pets
//                               : Icons
//                                   .cruelty_free,
//                           color:
//                               primaryColor,
//                           size: 52,
//                         ),
//                       );
//                     },
//                   ),

//                   // ==================================================
//                   // GRADIENT
//                   // ==================================================

//                   Positioned.fill(
//                     child: DecoratedBox(
//                       decoration:
//                           BoxDecoration(
//                         gradient:
//                             LinearGradient(
//                           begin: Alignment
//                               .topCenter,
//                           end: Alignment
//                               .bottomCenter,
//                           stops: const [
//                             0.42,
//                             1.0,
//                           ],
//                           colors: [
//                             Colors
//                                 .transparent,
//                             Colors.black
//                                 .withOpacity(
//                               0.75,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ==================================================
//                   // STATUS
//                   // ==================================================

//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 10,
//                         vertical: 6,
//                       ),
//                       decoration:
//                           BoxDecoration(
//                         color: isAvailable
//                             ? tealColor
//                             : pendingColor,
//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           18,
//                         ),
//                       ),
//                       child: Text(
//                         pet['status']
//                             .toString()
//                             .toUpperCase(),
//                         style:
//                             const TextStyle(
//                           color:
//                               Colors.white,
//                           fontSize: 8,
//                           fontWeight:
//                               FontWeight.bold,
//                           letterSpacing:
//                               0.3,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ==================================================
//                   // FAVORITE
//                   // ==================================================

//                   Positioned(
//                     right: 11,
//                     bottom: 11,
//                     child: Material(
//                       color:
//                           Colors.transparent,
//                       child: InkWell(
//                         onTap: () {
//                           _showMessage(
//                             '${pet['name']} added to favorites.',
//                           );
//                         },
//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           50,
//                         ),
//                         child: Container(
//                           width: 36,
//                           height: 36,
//                           decoration:
//                               BoxDecoration(
//                             color: Colors
//                                 .white
//                                 .withOpacity(
//                               0.90,
//                             ),
//                             shape:
//                                 BoxShape.circle,
//                           ),
//                           child:
//                               const Icon(
//                             Icons
//                                 .favorite_border_rounded,
//                             size: 20,
//                             color:
//                                 Color(
//                               0xFF667477,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ==================================================
//                   // PET NAME
//                   // ==================================================

//                   Positioned(
//                     left: 14,
//                     right: 58,
//                     bottom: 13,
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment
//                               .start,
//                       children: [
//                         Text(
//                           pet['name']
//                               .toString(),
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow
//                                   .ellipsis,
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 20,
//                             fontWeight:
//                                 FontWeight.bold,
//                             height: 1.1,
//                           ),
//                         ),

//                         const SizedBox(
//                           height: 3,
//                         ),

//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow
//                                   .ellipsis,
//                           style:
//                               const TextStyle(
//                             color:
//                                 Colors.white,
//                             fontSize: 10,
//                             fontWeight:
//                                 FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // TAGS
//             // ==================================================

//             Container(
//               width: double.infinity,
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 11,
//                 9,
//                 11,
//                 10,
//               ),
//               child: SingleChildScrollView(
//                 scrollDirection:
//                     Axis.horizontal,
//                 physics:
//                     const BouncingScrollPhysics(),
//                 child: Row(
//                   children: [
//                     if (pet['vaccinated'] ==
//                         true)
//                       _buildPetTag(
//                         icon: Icons
//                             .vaccines_rounded,
//                         text: 'Vaccinated',
//                       ),

//                     if (pet['vaccinated'] ==
//                             true &&
//                         (pet['kidFriendly'] ==
//                                 true ||
//                             pet['energy'] !=
//                                 null))
//                       const SizedBox(
//                         width: 6,
//                       ),

//                     if (pet['kidFriendly'] ==
//                         true)
//                       _buildPetTag(
//                         icon: Icons
//                             .child_friendly_rounded,
//                         text: 'Good w/ Kids',
//                       ),

//                     if (pet['kidFriendly'] ==
//                             true &&
//                         pet['energy'] !=
//                             null)
//                       const SizedBox(
//                         width: 6,
//                       ),

//                     if (pet['energy'] !=
//                         null)
//                       _buildPetTag(
//                         icon:
//                             Icons.bolt_rounded,
//                         text:
//                             pet['energy']
//                                 .toString(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET TAG
//   // ============================================================

//   Widget _buildPetTag({
//     required IconData icon,
//     required String text,
//   }) {
//     return Container(
//       padding:
//           const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 5,
//       ),
//       decoration: BoxDecoration(
//         color:
//             const Color(0xFFE9F7F6),
//         borderRadius:
//             BorderRadius.circular(13),
//       ),
//       child: Row(
//         mainAxisSize:
//             MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 11,
//             color: tealColor,
//           ),
//           const SizedBox(width: 3),
//           Text(
//             text,
//             style:
//                 const TextStyle(
//               color:
//                   Color(0xFF34706C),
//               fontSize: 8,
//               fontWeight:
//                   FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       padding:
//           const EdgeInsets.symmetric(
//         vertical: 55,
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 70,
//             height: 70,
//             decoration:
//                 const BoxDecoration(
//               color: Color(0xFFE7F5FA),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.search_off_rounded,
//               size: 34,
//               color: primaryColor,
//             ),
//           ),

//           const SizedBox(height: 14),

//           const Text(
//             'No pets found',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 18,
//               fontWeight:
//                   FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 5),

//           const Text(
//             'Try another search or change your filters.',
//             textAlign:
//                 TextAlign.center,
//             style: TextStyle(
//               color: secondaryText,
//               fontSize: 12,
//               height: 1.4,
//             ),
//           ),

//           const SizedBox(height: 16),

//           OutlinedButton(
//             onPressed: _clearAllFilters,
//             style:
//                 OutlinedButton.styleFrom(
//               foregroundColor:
//                   primaryColor,
//               side:
//                   const BorderSide(
//                 color: primaryColor,
//               ),
//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(
//                   22,
//                 ),
//               ),
//               padding:
//                   const EdgeInsets
//                       .symmetric(
//                 horizontal: 18,
//                 vertical: 10,
//               ),
//             ),
//             child: const Text(
//               'Clear Filters',
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight:
//                     FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // FILTER BOTTOM SHEET
//   // ============================================================

//   void _showFilterDialog({
//     required String title,
//     required String currentValue,
//     required List<String> options,
//     required ValueChanged<String>
//         onSelected,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor:
//           Colors.transparent,
//       isScrollControlled: true,
//       builder: (sheetContext) {
//         return Container(
//           width: double.infinity,
//           decoration:
//               const BoxDecoration(
//             color: Colors.white,
//             borderRadius:
//                 BorderRadius.vertical(
//               top: Radius.circular(24),
//             ),
//           ),
//           child: SafeArea(
//             top: false,
//             child: Padding(
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 18,
//                 10,
//                 18,
//                 18,
//               ),
//               child: Column(
//                 mainAxisSize:
//                     MainAxisSize.min,
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   // HANDLE
//                   Center(
//                     child: Container(
//                       width: 38,
//                       height: 4,
//                       decoration:
//                           BoxDecoration(
//                         color:
//                             const Color(
//                           0xFFD5DDDF,
//                         ),
//                         borderRadius:
//                             BorderRadius
//                                 .circular(
//                           5,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(
//                     height: 18,
//                   ),

//                   Text(
//                     'Filter by $title',
//                     style:
//                         const TextStyle(
//                       color: darkText,
//                       fontSize: 19,
//                       fontWeight:
//                           FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(
//                     height: 6,
//                   ),

//                   const Text(
//                     'Choose an option below.',
//                     style:
//                         TextStyle(
//                       color:
//                           secondaryText,
//                       fontSize: 12,
//                     ),
//                   ),

//                   const SizedBox(
//                     height: 12,
//                   ),

//                   ...options.map(
//                     (option) {
//                       final bool selected =
//                           option ==
//                               currentValue;

//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.pop(
//                             sheetContext,
//                           );

//                           onSelected(
//                             option,
//                           );
//                         },
//                         child: Container(
//                           width:
//                               double.infinity,
//                           margin:
//                               const EdgeInsets
//                                   .only(
//                             bottom: 7,
//                           ),
//                           padding:
//                               const EdgeInsets
//                                   .symmetric(
//                             horizontal: 13,
//                             vertical: 13,
//                           ),
//                           decoration:
//                               BoxDecoration(
//                             color: selected
//                                 ? const Color(
//                                     0xFFFFEEE8,
//                                   )
//                                 : const Color(
//                                     0xFFF7FAFB,
//                                   ),
//                             borderRadius:
//                                 BorderRadius
//                                     .circular(
//                               11,
//                             ),
//                             border:
//                                 Border.all(
//                               color: selected
//                                   ? primaryColor
//                                   : const Color(
//                                       0xFFE4EAEC,
//                                     ),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   option,
//                                   style:
//                                       TextStyle(
//                                     color:
//                                         selected
//                                             ? primaryColor
//                                             : darkText,
//                                     fontSize:
//                                         13,
//                                     fontWeight:
//                                         selected
//                                             ? FontWeight.w600
//                                             : FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                               if (selected)
//                                 const Icon(
//                                   Icons
//                                       .check_circle_rounded,
//                                   color:
//                                       primaryColor,
//                                   size: 19,
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // CLEAR ALL FILTERS
//   // ============================================================

//   void _clearAllFilters() {
//     setState(() {
//       selectedCategory = 'All';
//       selectedBreed = 'All Breeds';
//       selectedAge = 'Any Age';
//       selectedGender = 'Any Gender';
//       selectedStatus = 'All Status';
//       _searchController.clear();
//     });
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context)
//         .showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style:
//               const TextStyle(
//             fontSize: 12,
//           ),
//         ),
//         behavior:
//             SnackBarBehavior.floating,
//         duration:
//             const Duration(
//           seconds: 2,
//         ),
//         margin:
//             const EdgeInsets.fromLTRB(
//           16,
//           0,
//           16,
//           16,
//         ),
//         shape:
//             RoundedRectangleBorder(
//           borderRadius:
//               BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }
// }

















// import 'package:flutter/material.dart';

// import 'pet_details_screen.dart';

// class PetsScreen extends StatefulWidget {
//   const PetsScreen({super.key});

//   @override
//   State<PetsScreen> createState() => _PetsScreenState();
// }

// class _PetsScreenState extends State<PetsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   final Color tealColor = const Color(0xFF008F82);
//   final Color pendingColor = const Color(0xFFB65C32);

//   // ============================================================
//   // CONTROLLERS
//   // ============================================================

//   final TextEditingController _searchController =
//       TextEditingController();

//   // ============================================================
//   // FILTER
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Dogs',
//     'Cats',
//   ];

//   // ============================================================
//   // PET DATA
//   // ============================================================

//   final List<Map<String, dynamic>> pets = [
//     {
//       'name': 'Bella',
//       'breed': 'Golden Retriever',
//       'age': '2 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': true,
//       'energy': 'High Energy',
//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=1200',
//       'category': 'Dogs',

//       // DETAILS
//       'weight': '65 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Friendly',
//         'Active',
//         'Good with Kids',
//       ],
//       'about':
//           'Bella is a sweet, energetic dog who loves everyone she meets. She was brought to our shelter when her previous owners had to move overseas. She thrives on outdoor activities and would make a perfect companion for an active family. She already knows basic commands and is fully house-trained.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Domestic Longhair',
//       'age': '4 yrs',
//       'gender': 'Male',
//       'status': 'Pending',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Calm',
//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=1200',
//       'category': 'Cats',

//       // DETAILS
//       'weight': '11 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Calm',
//         'Gentle',
//         'Independent',
//       ],
//       'about':
//           'Oliver is a calm and gentle cat who enjoys quiet environments and relaxing indoors. He is affectionate once he gets comfortable and would be a wonderful companion for someone looking for a peaceful pet.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Scout',
//       'breed': 'Terrier Mix',
//       'age': '1 yr',
//       'gender': 'Male',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'High Energy',
//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=1200',
//       'category': 'Dogs',

//       // DETAILS
//       'weight': '22 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Playful',
//         'Active',
//         'Loyal',
//       ],
//       'about':
//           'Scout is a playful young dog full of energy. He loves exploring, playing outdoors, and spending time with people. He would be a great match for an active family who can give him plenty of exercise and attention.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Calico',
//       'age': '3 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Indoor Only',
//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=1200',
//       'category': 'Cats',

//       // DETAILS
//       'weight': '9 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Gentle',
//         'Quiet',
//         'Affectionate',
//       ],
//       'about':
//           'Luna is a gentle and affectionate cat who prefers a calm indoor environment. She enjoys relaxing in cozy spaces and slowly building trust with her humans.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//   ];

//   // ============================================================
//   // LIFECYCLE
//   // ============================================================

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: backgroundColor,
//       child: Column(
//         children: [
//           _buildHeader(),

//           Expanded(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.fromLTRB(
//                 12,
//                 14,
//                 12,
//                 24,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // SEARCH
//                   _buildSearchBar(),

//                   const SizedBox(height: 12),

//                   // CATEGORIES
//                   _buildCategoryFilter(),

//                   const SizedBox(height: 12),

//                   // FILTER BUTTONS
//                   _buildFilterButtons(),

//                   const SizedBox(height: 18),

//                   // PET LIST
//                   _buildPetList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       height: 64,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE2E8EA),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // PROFILE IMAGE
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFD9E1E4),
//                 width: 1,
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           // APP NAME
//           Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // SEARCH ICON
//           IconButton(
//             onPressed: () {
//               FocusScope.of(context).requestFocus(
//                 FocusNode(),
//               );
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 40,
//               minHeight: 40,
//             ),
//             icon: Icon(
//               Icons.search_rounded,
//               color: darkText,
//               size: 23,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _buildSearchBar() {
//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.025),
//             blurRadius: 5,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _searchController,
//         onChanged: (_) {
//           setState(() {});
//         },
//         style: TextStyle(
//           color: darkText,
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: const InputDecoration(
//           hintText: 'Search by name or breed',
//           hintStyle: TextStyle(
//             color: Color(0xFF92999B),
//             fontSize: 12,
//           ),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             size: 21,
//             color: Color(0xFF7C8588),
//           ),
//           prefixIconConstraints: BoxConstraints(
//             minWidth: 48,
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             vertical: 16,
//             horizontal: 8,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY FILTER
//   // ============================================================

//   Widget _buildCategoryFilter() {
//     return Row(
//       children: categories.map((category) {
//         final bool selected =
//             selectedCategory == category;

//         return Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 3,
//             ),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(
//                   milliseconds: 180,
//                 ),
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : const Color(0xFFE7F5FA),
//                   borderRadius:
//                       BorderRadius.circular(25),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // FILTER BUTTONS
//   // ============================================================

//   Widget _buildFilterButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Breed',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Breed',
//                 options: [
//                   'All Breeds',
//                   'Golden Retriever',
//                   'Domestic Longhair',
//                   'Terrier Mix',
//                   'Calico',
//                 ],
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Age',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Age',
//                 options: [
//                   'Any Age',
//                   'Under 1 year',
//                   '1 - 3 years',
//                   '4+ years',
//                 ],
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Gender',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Gender',
//                 options: [
//                   'Any Gender',
//                   'Male',
//                   'Female',
//                 ],
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Status',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Status',
//                 options: [
//                   'All Status',
//                   'Available',
//                   'Pending',
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // ============================================================
//   // SMALL FILTER
//   // ============================================================

//   Widget _buildSmallFilter({
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 42,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(9),
//           border: Border.all(
//             color: const Color(0xFFD8E2E5),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Flexible(
//               child: Text(
//                 label,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),

//             const SizedBox(width: 2),

//             const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               size: 16,
//               color: Color(0xFF697578),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET LIST
//   // ============================================================

//   Widget _buildPetList() {
//     final String searchText =
//         _searchController.text.trim().toLowerCase();

//     final List<Map<String, dynamic>> filteredPets =
//         pets.where((pet) {
//       final bool categoryMatch =
//           selectedCategory == 'All' ||
//               pet['category'] == selectedCategory;

//       final bool searchMatch =
//           searchText.isEmpty ||
//               pet['name']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText) ||
//               pet['breed']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText);

//       return categoryMatch && searchMatch;
//     }).toList();

//     if (filteredPets.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       children: filteredPets.map((pet) {
//         return Padding(
//           padding: const EdgeInsets.only(
//             bottom: 14,
//           ),
//           child: _buildPetCard(pet),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // PET CARD
//   // ============================================================

//   Widget _buildPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     final bool isAvailable =
//         pet['status'] == 'Available';

//     return GestureDetector(
//       onTap: () {
//         // ======================================================
//         // OPEN SEPARATE PET DETAILS SCREEN
//         // ======================================================

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => PetDetailsScreen(
//               pet: pet,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: const Color(0xFFDCE7EA),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.035),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           children: [
//             // ==================================================
//             // IMAGE
//             // ==================================================

//             AspectRatio(
//               aspectRatio: 1.55,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.network(
//                     pet['image'].toString(),
//                     fit: BoxFit.cover,
//                     alignment: Alignment.center,
//                     errorBuilder:
//                         (_, __, ___) {
//                       return Container(
//                         color:
//                             const Color(0xFFE9EEF0),
//                         child: Icon(
//                           pet['category'] ==
//                                   'Dogs'
//                               ? Icons.pets
//                               : Icons.cruelty_free,
//                           color: primaryColor,
//                           size: 55,
//                         ),
//                       );
//                     },
//                   ),

//                   // IMAGE GRADIENT
//                   Positioned.fill(
//                     child: DecoratedBox(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin:
//                               Alignment.topCenter,
//                           end:
//                               Alignment.bottomCenter,
//                           stops: const [
//                             0.45,
//                             1.0,
//                           ],
//                           colors: [
//                             Colors.transparent,
//                             Colors.black
//                                 .withOpacity(0.72),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // STATUS
//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: Container(
//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 11,
//                         vertical: 7,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isAvailable
//                             ? tealColor
//                             : pendingColor,
//                         borderRadius:
//                             BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         pet['status']
//                             .toString()
//                             .toUpperCase(),
//                         style:
//                             const TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight:
//                               FontWeight.bold,
//                           letterSpacing: 0.2,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // FAVORITE
//                   Positioned(
//                     right: 12,
//                     bottom: 12,
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius:
//                             BorderRadius.circular(50),
//                         onTap: () {
//                           _showMessage(
//                             '${pet['name']} added to favorites.',
//                           );
//                         },
//                         child: Container(
//                           width: 43,
//                           height: 43,
//                           decoration: BoxDecoration(
//                             color: Colors.white
//                                 .withOpacity(0.88),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons
//                                 .favorite_border_rounded,
//                             size: 25,
//                             color:
//                                 Color(0xFF667477),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // PET NAME + BASIC INFO
//                   Positioned(
//                     left: 16,
//                     right: 62,
//                     bottom: 14,
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           pet['name'].toString(),
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight:
//                                 FontWeight.bold,
//                             height: 1.1,
//                           ),
//                         ),

//                         const SizedBox(height: 4),

//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 11,
//                             fontWeight:
//                                 FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // PET TAGS
//             // ==================================================

//             Container(
//               width: double.infinity,
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 12,
//                 9,
//                 12,
//                 10,
//               ),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 physics:
//                     const BouncingScrollPhysics(),
//                 child: Row(
//                   children: [
//                     if (pet['vaccinated'] == true)
//                       _buildPetTag(
//                         icon:
//                             Icons.vaccines_rounded,
//                         text: 'Vaccinated',
//                       ),

//                     if (pet['vaccinated'] == true &&
//                         (pet['kidFriendly'] == true ||
//                             pet['energy'] != null))
//                       const SizedBox(width: 6),

//                     if (pet['kidFriendly'] == true)
//                       _buildPetTag(
//                         icon: Icons
//                             .child_friendly_rounded,
//                         text: 'Good w/ Kids',
//                       ),

//                     if (pet['kidFriendly'] == true &&
//                         pet['energy'] != null)
//                       const SizedBox(width: 6),

//                     if (pet['energy'] != null)
//                       _buildPetTag(
//                         icon: Icons.bolt_rounded,
//                         text: pet['energy'],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET TAG
//   // ============================================================

//   Widget _buildPetTag({
//     required IconData icon,
//     required String text,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE9F7F6),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 12,
//             color: tealColor,
//           ),

//           const SizedBox(width: 4),

//           Text(
//             text,
//             style: const TextStyle(
//               color: Color(0xFF34706C),
//               fontSize: 9,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         vertical: 70,
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.search_off_rounded,
//             size: 58,
//             color: primaryColor,
//           ),

//           const SizedBox(height: 14),

//           Text(
//             'No pets found',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 6),

//           const Text(
//             'Try another search or category.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 13,
//             ),
//           ),

//           const SizedBox(height: 18),

//           OutlinedButton(
//             onPressed: () {
//               setState(() {
//                 selectedCategory = 'All';
//                 _searchController.clear();
//               });
//             },
//             style: OutlinedButton.styleFrom(
//               foregroundColor: primaryColor,
//               side: BorderSide(
//                 color: primaryColor,
//               ),
//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(20),
//               ),
//             ),
//             child: const Text(
//               'Clear Filters',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // FILTER DIALOG
//   // ============================================================

//   void _showFilterDialog({
//     required String title,
//     required List<String> options,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(22),
//         ),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(
//               20,
//               16,
//               20,
//               20,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 // HANDLE
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius:
//                           BorderRadius.circular(5),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 Text(
//                   'Filter by $title',
//                   style: TextStyle(
//                     color: darkText,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 ...options.map(
//                   (option) {
//                     return ListTile(
//                       contentPadding:
//                           EdgeInsets.zero,
//                       title: Text(
//                         option,
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 14,
//                         ),
//                       ),
//                       trailing: const Icon(
//                         Icons.chevron_right_rounded,
//                         color: Colors.grey,
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);

//                         _showMessage(
//                           '$title: $option',
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }
















// import 'package:flutter/material.dart';

// class PetsScreen extends StatefulWidget {
//   const PetsScreen({super.key});

//   @override
//   State<PetsScreen> createState() => _PetsScreenState();
// }

// class _PetsScreenState extends State<PetsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   final Color tealColor = const Color(0xFF008F82);
//   final Color pendingColor = const Color(0xFFB65C32);

//   // Detail page colors
//   final Color detailBrown = const Color(0xFF604A45);
//   final Color detailBlue = const Color(0xFFEFF9FD);
//   final Color lightBlue = const Color(0xFFE4F5FB);

//   // ============================================================
//   // CONTROLLERS
//   // ============================================================

//   final TextEditingController _searchController =
//       TextEditingController();

//   // ============================================================
//   // FILTER
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Dogs',
//     'Cats',
//   ];

//   // ============================================================
//   // PET DATA
//   // ============================================================

//   final List<Map<String, dynamic>> pets = [
//     {
//       'name': 'Bella',
//       'breed': 'Golden Retriever Mix',
//       'age': '2 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': true,
//       'energy': 'High Energy',
//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=1200',
//       'category': 'Dogs',

//       // DETAIL INFORMATION
//       'weight': '65 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Friendly',
//         'Active',
//         'Good with Kids',
//       ],
//       'about':
//           'Bella is a sweet, energetic dog who loves everyone she meets. She was brought to our shelter when her previous owners had to move overseas. She thrives on outdoor activities and would make a perfect companion for an active family. She already knows basic commands and is fully house-trained.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Domestic Longhair',
//       'age': '4 yrs',
//       'gender': 'Male',
//       'status': 'Pending',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Calm',
//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=1200',
//       'category': 'Cats',

//       'weight': '11 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Calm',
//         'Gentle',
//         'Independent',
//       ],
//       'about':
//           'Oliver is a calm and gentle cat who enjoys quiet environments and relaxing indoors. He is affectionate once he gets comfortable and would be a wonderful companion for someone looking for a peaceful pet.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Scout',
//       'breed': 'Terrier Mix',
//       'age': '1 yr',
//       'gender': 'Male',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'High Energy',
//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=1200',
//       'category': 'Dogs',

//       'weight': '22 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Playful',
//         'Active',
//         'Loyal',
//       ],
//       'about':
//           'Scout is a playful young dog full of energy. He loves exploring, playing outdoors, and spending time with people. He would be a great match for an active family who can give him plenty of exercise and attention.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Calico',
//       'age': '3 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Indoor Only',
//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=1200',
//       'category': 'Cats',

//       'weight': '9 lbs',
//       'vaccinationStatus': 'Up to date',
//       'personality': [
//         'Gentle',
//         'Quiet',
//         'Affectionate',
//       ],
//       'about':
//           'Luna is a gentle and affectionate cat who prefers a calm indoor environment. She enjoys relaxing in cozy spaces and slowly building trust with her humans.',
//       'shelter': 'JAGNA ANIMAL LOVER AND RESCUE GROUP',
//       'shelterPhone': 'Contact Shelter',
//     },
//   ];

//   // ============================================================
//   // LIFECYCLE
//   // ============================================================

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: backgroundColor,
//       child: Column(
//         children: [
//           _buildHeader(),

//           Expanded(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.fromLTRB(
//                 12,
//                 14,
//                 12,
//                 24,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSearchBar(),

//                   const SizedBox(height: 12),

//                   _buildCategoryFilter(),

//                   const SizedBox(height: 12),

//                   _buildFilterButtons(),

//                   const SizedBox(height: 18),

//                   _buildPetList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       height: 64,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE2E8EA),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFD9E1E4),
//                 width: 1,
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           IconButton(
//             onPressed: () {
//               FocusScope.of(context).requestFocus(
//                 FocusNode(),
//               );
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 40,
//               minHeight: 40,
//             ),
//             icon: Icon(
//               Icons.search_rounded,
//               color: darkText,
//               size: 23,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _buildSearchBar() {
//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.025),
//             blurRadius: 5,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _searchController,
//         onChanged: (_) {
//           setState(() {});
//         },
//         style: TextStyle(
//           color: darkText,
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: const InputDecoration(
//           hintText: 'Search by name or breed',
//           hintStyle: TextStyle(
//             color: Color(0xFF92999B),
//             fontSize: 12,
//           ),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             size: 21,
//             color: Color(0xFF7C8588),
//           ),
//           prefixIconConstraints: BoxConstraints(
//             minWidth: 48,
//           ),
//           border: InputBorder.none,
//           contentPadding: EdgeInsets.symmetric(
//             vertical: 16,
//             horizontal: 8,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY FILTER
//   // ============================================================

//   Widget _buildCategoryFilter() {
//     return Row(
//       children: categories.map((category) {
//         final bool selected =
//             selectedCategory == category;

//         return Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 3,
//             ),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration:
//                     const Duration(milliseconds: 180),
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : const Color(0xFFE7F5FA),
//                   borderRadius:
//                       BorderRadius.circular(25),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // FILTER BUTTONS
//   // ============================================================

//   Widget _buildFilterButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Breed',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Breed',
//                 options: [
//                   'All Breeds',
//                   'Golden Retriever',
//                   'Domestic Longhair',
//                   'Terrier Mix',
//                   'Calico',
//                 ],
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Age',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Age',
//                 options: [
//                   'Any Age',
//                   'Under 1 year',
//                   '1 - 3 years',
//                   '4+ years',
//                 ],
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Gender',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Gender',
//                 options: [
//                   'Any Gender',
//                   'Male',
//                   'Female',
//                 ],
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Status',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Status',
//                 options: [
//                   'All Status',
//                   'Available',
//                   'Pending',
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSmallFilter({
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 42,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(9),
//           border: Border.all(
//             color: const Color(0xFFD8E2E5),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Flexible(
//               child: Text(
//                 label,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),

//             const SizedBox(width: 2),

//             const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               size: 16,
//               color: Color(0xFF697578),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET LIST
//   // ============================================================

//   Widget _buildPetList() {
//     final String searchText =
//         _searchController.text.trim().toLowerCase();

//     List<Map<String, dynamic>> filteredPets =
//         pets.where((pet) {
//       final bool categoryMatch =
//           selectedCategory == 'All' ||
//               pet['category'] == selectedCategory;

//       final bool searchMatch =
//           searchText.isEmpty ||
//               pet['name']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText) ||
//               pet['breed']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText);

//       return categoryMatch && searchMatch;
//     }).toList();

//     if (filteredPets.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       children: filteredPets.map((pet) {
//         return Padding(
//           padding: const EdgeInsets.only(
//             bottom: 14,
//           ),
//           child: _buildPetCard(pet),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // PET CARD
//   // ============================================================

//   Widget _buildPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     final bool isAvailable =
//         pet['status'] == 'Available';

//     return GestureDetector(
//       onTap: () {
//         _showPetDetails(pet);
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: const Color(0xFFDCE7EA),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.035),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           children: [
//             AspectRatio(
//               aspectRatio: 1.55,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.network(
//                     pet['image'].toString(),
//                     fit: BoxFit.cover,
//                     alignment: Alignment.center,
//                     errorBuilder:
//                         (_, __, ___) {
//                       return Container(
//                         color:
//                             const Color(0xFFE9EEF0),
//                         child: Icon(
//                           pet['category'] ==
//                                   'Dogs'
//                               ? Icons.pets
//                               : Icons.cruelty_free,
//                           color: primaryColor,
//                           size: 55,
//                         ),
//                       );
//                     },
//                   ),

//                   Positioned.fill(
//                     child: DecoratedBox(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin:
//                               Alignment.topCenter,
//                           end:
//                               Alignment.bottomCenter,
//                           stops: const [
//                             0.45,
//                             1.0,
//                           ],
//                           colors: [
//                             Colors.transparent,
//                             Colors.black
//                                 .withOpacity(0.72),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: Container(
//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 11,
//                         vertical: 7,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isAvailable
//                             ? tealColor
//                             : pendingColor,
//                         borderRadius:
//                             BorderRadius.circular(
//                           20,
//                         ),
//                       ),
//                       child: Text(
//                         pet['status']
//                             .toString()
//                             .toUpperCase(),
//                         style:
//                             const TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight:
//                               FontWeight.bold,
//                           letterSpacing: 0.2,
//                         ),
//                       ),
//                     ),
//                   ),

//                   Positioned(
//                     right: 12,
//                     bottom: 12,
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius:
//                             BorderRadius.circular(
//                           50,
//                         ),
//                         onTap: () {
//                           _showFilterMessage(
//                             '${pet['name']} added to favorites.',
//                           );
//                         },
//                         child: Container(
//                           width: 43,
//                           height: 43,
//                           decoration: BoxDecoration(
//                             color: Colors.white
//                                 .withOpacity(0.88),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons
//                                 .favorite_border_rounded,
//                             size: 25,
//                             color:
//                                 Color(0xFF667477),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   Positioned(
//                     left: 16,
//                     right: 62,
//                     bottom: 14,
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           pet['name'].toString(),
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight:
//                                 FontWeight.bold,
//                             height: 1.1,
//                           ),
//                         ),

//                         const SizedBox(height: 4),

//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 11,
//                             fontWeight:
//                                 FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Container(
//               width: double.infinity,
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 12,
//                 9,
//                 12,
//                 10,
//               ),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 physics:
//                     const BouncingScrollPhysics(),
//                 child: Row(
//                   children: [
//                     if (pet['vaccinated'] == true)
//                       _buildPetTag(
//                         icon:
//                             Icons.vaccines_rounded,
//                         text: 'Vaccinated',
//                       ),

//                     if (pet['vaccinated'] == true &&
//                         (pet['kidFriendly'] == true ||
//                             pet['energy'] != null))
//                       const SizedBox(width: 6),

//                     if (pet['kidFriendly'] == true)
//                       _buildPetTag(
//                         icon: Icons
//                             .child_friendly_rounded,
//                         text: 'Good w/ Kids',
//                       ),

//                     if (pet['kidFriendly'] == true &&
//                         pet['energy'] != null)
//                       const SizedBox(width: 6),

//                     if (pet['energy'] != null)
//                       _buildPetTag(
//                         icon: Icons.bolt_rounded,
//                         text: pet['energy'],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET TAG
//   // ============================================================

//   Widget _buildPetTag({
//     required IconData icon,
//     required String text,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE9F7F6),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 12,
//             color: tealColor,
//           ),

//           const SizedBox(width: 4),

//           Text(
//             text,
//             style: const TextStyle(
//               color: Color(0xFF34706C),
//               fontSize: 9,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         vertical: 70,
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.search_off_rounded,
//             size: 58,
//             color: primaryColor,
//           ),

//           const SizedBox(height: 14),

//           Text(
//             'No pets found',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 6),

//           const Text(
//             'Try another search or category.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 13,
//             ),
//           ),

//           const SizedBox(height: 18),

//           OutlinedButton(
//             onPressed: () {
//               setState(() {
//                 selectedCategory = 'All';
//                 _searchController.clear();
//               });
//             },
//             style: OutlinedButton.styleFrom(
//               foregroundColor: primaryColor,
//               side: BorderSide(
//                 color: primaryColor,
//               ),
//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(20),
//               ),
//             ),
//             child: const Text(
//               'Clear Filters',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // NEW PET DETAILS DESIGN
//   // ============================================================

//   void _showPetDetails(
//     Map<String, dynamic> pet,
//   ) {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Pet Details',
//       barrierColor: Colors.black.withOpacity(0.45),
//       transitionDuration:
//           const Duration(milliseconds: 250),
//       pageBuilder: (
//         dialogContext,
//         animation,
//         secondaryAnimation,
//       ) {
//         return _buildPetDetailsPage(
//           dialogContext,
//           pet,
//         );
//       },
//       transitionBuilder: (
//         context,
//         animation,
//         secondaryAnimation,
//         child,
//       ) {
//         final curvedAnimation = CurvedAnimation(
//           parent: animation,
//           curve: Curves.easeOutCubic,
//         );

//         return FadeTransition(
//           opacity: curvedAnimation,
//           child: child,
//         );
//       },
//     );
//   }

//   // ============================================================
//   // PET DETAILS PAGE
//   // ============================================================

//   Widget _buildPetDetailsPage(
//     BuildContext dialogContext,
//     Map<String, dynamic> pet,
//   ) {
//     final bool isAvailable =
//         pet['status'] == 'Available';

//     return Material(
//       color: Colors.transparent,
//       child: SafeArea(
//         child: Container(
//           color: detailBrown,
//           child: Stack(
//             children: [
//               // ==================================================
//               // MAIN SCROLLABLE CONTENT
//               // ==================================================

//               SingleChildScrollView(
//                 physics:
//                     const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.only(
//                   bottom: 145,
//                 ),
//                 child: Column(
//                   children: [
//                     // ============================================
//                     // HERO IMAGE
//                     // ============================================

//                     Container(
//                       height: 320,
//                       margin: const EdgeInsets.fromLTRB(
//                         14,
//                         0,
//                         14,
//                         0,
//                       ),
//                       child: Stack(
//                         children: [
//                           Positioned.fill(
//                             child: ClipRRect(
//                               borderRadius:
//                                   const BorderRadius.vertical(
//                                 bottom:
//                                     Radius.circular(24),
//                               ),
//                               child: Image.network(
//                                 pet['image'].toString(),
//                                 fit: BoxFit.cover,
//                                 alignment:
//                                     Alignment.center,
//                                 errorBuilder:
//                                     (_, __, ___) {
//                                   return Container(
//                                     color:
//                                         const Color(
//                                       0xFFE9EEF0,
//                                     ),
//                                     child: Icon(
//                                       pet['category'] ==
//                                               'Dogs'
//                                           ? Icons.pets
//                                           : Icons
//                                               .cruelty_free,
//                                       size: 70,
//                                       color:
//                                           primaryColor,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),

//                           // IMAGE DARK GRADIENT
//                           Positioned.fill(
//                             child: ClipRRect(
//                               borderRadius:
//                                   const BorderRadius.vertical(
//                                 bottom:
//                                     Radius.circular(24),
//                               ),
//                               child: DecoratedBox(
//                                 decoration:
//                                     BoxDecoration(
//                                   gradient:
//                                       LinearGradient(
//                                     begin:
//                                         Alignment.topCenter,
//                                     end:
//                                         Alignment.bottomCenter,
//                                     colors: [
//                                       Colors.black
//                                           .withOpacity(
//                                         0.08,
//                                       ),
//                                       Colors.transparent,
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           // BACK BUTTON
//                           Positioned(
//                             top: 12,
//                             left: 10,
//                             child: _buildDetailCircleButton(
//                               icon: Icons
//                                   .arrow_back_ios_new_rounded,
//                               onTap: () {
//                                 Navigator.pop(
//                                   dialogContext,
//                                 );
//                               },
//                             ),
//                           ),

//                           // FAVORITE BUTTON
//                           Positioned(
//                             top: 12,
//                             right: 10,
//                             child: _buildDetailCircleButton(
//                               icon: Icons
//                                   .favorite_border_rounded,
//                               iconColor: primaryColor,
//                               onTap: () {
//                                 _showFilterMessage(
//                                   '${pet['name']} added to favorites.',
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // ============================================
//                     // WHITE INFORMATION CARD
//                     // ============================================

//                     Transform.translate(
//                       offset: const Offset(0, -20),
//                       child: Container(
//                         width: double.infinity,
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                         ),
//                         padding: const EdgeInsets.fromLTRB(
//                           12,
//                           14,
//                           12,
//                           16,
//                         ),
//                         decoration: BoxDecoration(
//                           color: detailBlue,
//                           borderRadius:
//                               BorderRadius.circular(22),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black
//                                   .withOpacity(0.08),
//                               blurRadius: 8,
//                               offset:
//                                   const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             // ==================================
//                             // NAME
//                             // ==================================

//                             Text(
//                               pet['name'].toString(),
//                               style: TextStyle(
//                                 color: darkText,
//                                 fontSize: 20,
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(height: 3),

//                             Text(
//                               '${pet['breed']} • ${pet['age']} • ${pet['gender']}',
//                               style: const TextStyle(
//                                 color:
//                                     Color(0xFF45565B),
//                                 fontSize: 9,
//                                 fontWeight:
//                                     FontWeight.w400,
//                               ),
//                             ),

//                             const SizedBox(height: 12),

//                             Container(
//                               height: 1,
//                               color:
//                                   const Color(0xFFD9E8ED),
//                             ),

//                             const SizedBox(height: 11),

//                             // ==================================
//                             // WEIGHT / VACCINATION
//                             // ==================================

//                             Row(
//                               children: [
//                                 Expanded(
//                                   child:
//                                       _buildDetailInfoBox(
//                                     title: 'Weight',
//                                     value: pet['weight']
//                                         .toString(),
//                                     icon: Icons
//                                         .monitor_weight_outlined,
//                                   ),
//                                 ),

//                                 const SizedBox(width: 7),

//                                 Expanded(
//                                   child:
//                                       _buildDetailInfoBox(
//                                     title:
//                                         'Vaccination',
//                                     value: pet[
//                                             'vaccinationStatus']
//                                         .toString(),
//                                     icon: Icons
//                                         .vaccines_outlined,
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 12),

//                             // ==================================
//                             // PERSONALITY
//                             // ==================================

//                             Text(
//                               'Personality',
//                               style: TextStyle(
//                                 color: darkText,
//                                 fontSize: 10,
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(height: 6),

//                             Wrap(
//                               spacing: 5,
//                               runSpacing: 5,
//                               children: (
//                                 pet['personality']
//                                     as List<dynamic>
//                               ).map(
//                                 (personality) {
//                                   return _buildPersonalityChip(
//                                     personality
//                                         .toString(),
//                                   );
//                                 },
//                               ).toList(),
//                             ),

//                             const SizedBox(height: 14),

//                             // ==================================
//                             // ABOUT
//                             // ==================================

//                             Text(
//                               'About ${pet['name']}',
//                               style: TextStyle(
//                                 color: darkText,
//                                 fontSize: 10,
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(height: 5),

//                             Text(
//                               pet['about'].toString(),
//                               style: const TextStyle(
//                                 color:
//                                     Color(0xFF4B5E63),
//                                 fontSize: 8,
//                                 height: 1.45,
//                               ),
//                             ),

//                             const SizedBox(height: 15),

//                             // ==================================
//                             // SHELTER CARD
//                             // ==================================

//                             _buildShelterCard(
//                               pet,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // ==================================================
//               // FIXED BOTTOM ACTION AREA
//               // ==================================================

//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   padding: const EdgeInsets.fromLTRB(
//                     14,
//                     10,
//                     14,
//                     10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFEAF8FC),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black
//                             .withOpacity(0.08),
//                         blurRadius: 8,
//                         offset: const Offset(
//                           0,
//                           -2,
//                         ),
//                       ),
//                     ],
//                   ),
//                   child: SafeArea(
//                     top: false,
//                     child: Column(
//                       children: [
//                         // ========================================
//                         // AR PREVIEW + VISIT
//                         // ========================================

//                         Row(
//                           children: [
//                             Expanded(
//                               child:
//                                   _buildSecondaryButton(
//                                 label: 'AR Preview',
//                                 icon: Icons
//                                     .view_in_ar_outlined,
//                                 filled: true,
//                                 onTap: () {
//                                   Navigator.pop(
//                                     dialogContext,
//                                   );

//                                   _showFilterMessage(
//                                     'AR Preview for ${pet['name']} coming soon.',
//                                   );
//                                 },
//                               ),
//                             ),

//                             const SizedBox(width: 7),

//                             Expanded(
//                               child:
//                                   _buildSecondaryButton(
//                                 label: 'Visit',
//                                 icon: Icons
//                                     .calendar_month_outlined,
//                                 filled: false,
//                                 onTap: () {
//                                   Navigator.pop(
//                                     dialogContext,
//                                   );

//                                   _showFilterMessage(
//                                     'Visit request for ${pet['name']} coming soon.',
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 7),

//                         // ========================================
//                         // APPLY FOR ADOPTION
//                         // ========================================

//                         SizedBox(
//                           width: double.infinity,
//                           height: 38,
//                           child: ElevatedButton(
//                             onPressed: isAvailable
//                                 ? () {
//                                     Navigator.pop(
//                                       dialogContext,
//                                     );

//                                     _showFilterMessage(
//                                       'Adoption request for ${pet['name']} coming soon.',
//                                     );
//                                   }
//                                 : null,
//                             style:
//                                 ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   primaryColor,
//                               disabledBackgroundColor:
//                                   const Color(
//                                 0xFFB9B9B9,
//                               ),
//                               foregroundColor:
//                                   Colors.white,
//                               disabledForegroundColor:
//                                   Colors.white,
//                               elevation: 0,
//                               shape:
//                                   RoundedRectangleBorder(
//                                 borderRadius:
//                                     BorderRadius.circular(
//                                   22,
//                                 ),
//                               ),
//                             ),
//                             child: Text(
//                               isAvailable
//                                   ? 'Apply for Adoption'
//                                   : 'Adoption Pending',
//                               style:
//                                   const TextStyle(
//                                 fontSize: 10,
//                                 fontWeight:
//                                     FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DETAIL CIRCLE BUTTON
//   // ============================================================

//   Widget _buildDetailCircleButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     Color iconColor = const Color(0xFF526069),
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius:
//             BorderRadius.circular(30),
//         child: Container(
//           width: 36,
//           height: 36,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.88),
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.08),
//                 blurRadius: 5,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Icon(
//             icon,
//             size: 15,
//             color: iconColor,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // DETAIL INFO BOX
//   // ============================================================

//   Widget _buildDetailInfoBox({
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     return Container(
//       height: 48,
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: lightBlue,
//         borderRadius: BorderRadius.circular(7),
//       ),
//       child: Column(
//         crossAxisAlignment:
//             CrossAxisAlignment.start,
//         mainAxisAlignment:
//             MainAxisAlignment.center,
//         children: [
//           Row(
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Color(0xFF617176),
//                   fontSize: 7,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),

//               const Spacer(),

//               Icon(
//                 icon,
//                 size: 10,
//                 color: const Color(0xFF7A989F),
//               ),
//             ],
//           ),

//           const SizedBox(height: 3),

//           Text(
//             value,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: darkText,
//               fontSize: 8,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PERSONALITY CHIP
//   // ============================================================

//   Widget _buildPersonalityChip(
//     String text,
//   ) {
//     IconData icon;

//     switch (text.toLowerCase()) {
//       case 'friendly':
//         icon = Icons.favorite_border_rounded;
//         break;

//       case 'active':
//       case 'playful':
//       case 'high energy':
//         icon = Icons.bolt_rounded;
//         break;

//       case 'good with kids':
//         icon = Icons.child_friendly_rounded;
//         break;

//       case 'calm':
//       case 'quiet':
//       case 'gentle':
//         icon = Icons.spa_outlined;
//         break;

//       case 'independent':
//         icon = Icons.self_improvement_outlined;
//         break;

//       case 'affectionate':
//         icon = Icons.favorite_border_rounded;
//         break;

//       case 'loyal':
//         icon = Icons.shield_outlined;
//         break;

//       default:
//         icon = Icons.pets_outlined;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 7,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFDDF2F1),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 8,
//             color: tealColor,
//           ),

//           const SizedBox(width: 3),

//           Text(
//             text,
//             style: const TextStyle(
//               color: Color(0xFF34706C),
//               fontSize: 6.5,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SHELTER CARD
//   // ============================================================

//   Widget _buildShelterCard(
//     Map<String, dynamic> pet,
//   ) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(7),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(9),
//         border: Border.all(
//           color: const Color(0xFFDDE9EC),
//         ),
//       ),
//       child: Row(
//         children: [
//           // SHELTER ICON
//           Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: const Color(0xFFE9F7F6),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.home_work_outlined,
//               size: 14,
//               color: Color(0xFF008F82),
//             ),
//           ),

//           const SizedBox(width: 7),

//           // SHELTER NAME
//           Expanded(
//             child: Column(
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'JAGNA ANIMAL LOVER AND',
//                   style: TextStyle(
//                     color: Color(0xFF425257),
//                     fontSize: 6.5,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 1),

//                 const Text(
//                   'RESCUE GROUP',
//                   style: TextStyle(
//                     color: Color(0xFF425257),
//                     fontSize: 6.5,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // PHONE BUTTON
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius:
//                   BorderRadius.circular(30),
//               onTap: () {
//                 _showFilterMessage(
//                   'Contacting shelter...',
//                 );
//               },
//               child: Container(
//                 width: 27,
//                 height: 27,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color:
//                         const Color(0xFFDCE7EA),
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.phone_outlined,
//                   size: 12,
//                   color: Color(0xFF6D7B7F),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SECONDARY ACTION BUTTON
//   // ============================================================

//   Widget _buildSecondaryButton({
//     required String label,
//     required IconData icon,
//     required bool filled,
//     required VoidCallback onTap,
//   }) {
//     return SizedBox(
//       height: 38,
//       child: ElevatedButton(
//         onPressed: onTap,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: filled
//               ? const Color(0xFFFFA45D)
//               : Colors.transparent,
//           foregroundColor: filled
//               ? const Color(0xFF7B421E)
//               : primaryColor,
//           elevation: 0,
//           side: BorderSide(
//             color: primaryColor,
//             width: filled ? 0 : 1,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(20),
//           ),
//           padding:
//               const EdgeInsets.symmetric(
//             horizontal: 8,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 11,
//             ),

//             const SizedBox(width: 4),

//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 8.5,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // FILTER DIALOG
//   // ============================================================

//   void _showFilterDialog({
//     required String title,
//     required List<String> options,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(22),
//         ),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(
//               20,
//               16,
//               20,
//               20,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius:
//                           BorderRadius.circular(5),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 Text(
//                   'Filter by $title',
//                   style: TextStyle(
//                     color: darkText,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 ...options.map(
//                   (option) {
//                     return ListTile(
//                       contentPadding:
//                           EdgeInsets.zero,
//                       title: Text(
//                         option,
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 14,
//                         ),
//                       ),
//                       trailing: const Icon(
//                         Icons.chevron_right_rounded,
//                         color: Colors.grey,
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);

//                         _showFilterMessage(
//                           '$title: $option',
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showFilterMessage(
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }
















// import 'package:flutter/material.dart';

// class PetsScreen extends StatefulWidget {
//   const PetsScreen({super.key});

//   @override
//   State<PetsScreen> createState() => _PetsScreenState();
// }

// class _PetsScreenState extends State<PetsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   final Color tealColor = const Color(0xFF008F82);
//   final Color pendingColor = const Color(0xFFB65C32);

//   // ============================================================
//   // CONTROLLERS
//   // ============================================================

//   final TextEditingController _searchController =
//       TextEditingController();

//   // ============================================================
//   // FILTER
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Dogs',
//     'Cats',
//   ];

//   // ============================================================
//   // PET DATA
//   // ============================================================

//   final List<Map<String, dynamic>> pets = [
//     {
//       'name': 'Bella',
//       'breed': 'Golden Retriever Mix',
//       'age': '2 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': true,
//       'energy': 'High Energy',
//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=1200',
//       'category': 'Dogs',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Domestic Longhair',
//       'age': '4 yrs',
//       'gender': 'Male',
//       'status': 'Pending',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Calm',
//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=1200',
//       'category': 'Cats',
//     },
//     {
//       'name': 'Scout',
//       'breed': 'Terrier Mix',
//       'age': '1 yr',
//       'gender': 'Male',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'High Energy',
//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=1200',
//       'category': 'Dogs',
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Calico',
//       'age': '3 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Indoor Only',
//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=1200',
//       'category': 'Cats',
//     },
//   ];

//   // ============================================================
//   // LIFECYCLE
//   // ============================================================

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: backgroundColor,
//       child: Column(
//         children: [
//           _buildHeader(),

//           Expanded(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.fromLTRB(
//                 12,
//                 14,
//                 12,
//                 24,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // SEARCH
//                   _buildSearchBar(),

//                   const SizedBox(height: 12),

//                   // DOG / CAT / ALL
//                   _buildCategoryFilter(),

//                   const SizedBox(height: 12),

//                   // BREED / AGE / GENDER / STATUS
//                   _buildFilterButtons(),

//                   const SizedBox(height: 18),

//                   // PET LIST
//                   _buildPetList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       height: 64,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE2E8EA),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // PROFILE IMAGE
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFD9E1E4),
//                 width: 1,
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           // APP NAME
//           Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // SEARCH ICON
//           IconButton(
//             onPressed: () {
//               FocusScope.of(context).requestFocus(
//                 FocusNode(),
//               );
//             },
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 40,
//               minHeight: 40,
//             ),
//             icon: Icon(
//               Icons.search_rounded,
//               color: darkText,
//               size: 23,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _buildSearchBar() {
//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.025),
//             blurRadius: 5,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: _searchController,
//         onChanged: (_) {
//           setState(() {});
//         },
//         style: TextStyle(
//           color: darkText,
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//         decoration: InputDecoration(
//           hintText: 'Search by name or breed',
//           hintStyle: const TextStyle(
//             color: Color(0xFF92999B),
//             fontSize: 12,
//           ),
//           prefixIcon: const Icon(
//             Icons.search_rounded,
//             size: 21,
//             color: Color(0xFF7C8588),
//           ),
//           prefixIconConstraints: const BoxConstraints(
//             minWidth: 48,
//           ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 16,
//             horizontal: 8,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY FILTER
//   // ============================================================

//   Widget _buildCategoryFilter() {
//     return Row(
//       children: categories.map((category) {
//         final bool selected =
//             selectedCategory == category;

//         return Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 3,
//             ),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration:
//                     const Duration(milliseconds: 180),
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : const Color(0xFFE7F5FA),
//                   borderRadius:
//                       BorderRadius.circular(25),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // FILTER BUTTONS
//   // ============================================================

//   Widget _buildFilterButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Breed',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Breed',
//                 options: [
//                   'All Breeds',
//                   'Golden Retriever',
//                   'Domestic Longhair',
//                   'Terrier Mix',
//                   'Calico',
//                 ],
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Age',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Age',
//                 options: [
//                   'Any Age',
//                   'Under 1 year',
//                   '1 - 3 years',
//                   '4+ years',
//                 ],
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Gender',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Gender',
//                 options: [
//                   'Any Gender',
//                   'Male',
//                   'Female',
//                 ],
//               );
//             },
//           ),
//         ),

//         const SizedBox(width: 7),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Status',
//             onTap: () {
//               _showFilterDialog(
//                 title: 'Status',
//                 options: [
//                   'All Status',
//                   'Available',
//                   'Pending',
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSmallFilter({
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 42,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(9),
//           border: Border.all(
//             color: const Color(0xFFD8E2E5),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment.center,
//           children: [
//             Flexible(
//               child: Text(
//                 label,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   color: darkText,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),

//             const SizedBox(width: 2),

//             const Icon(
//               Icons.keyboard_arrow_down_rounded,
//               size: 16,
//               color: Color(0xFF697578),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET LIST
//   // ============================================================

//   Widget _buildPetList() {
//     final String searchText =
//         _searchController.text.trim().toLowerCase();

//     List<Map<String, dynamic>> filteredPets =
//         pets.where((pet) {
//       final bool categoryMatch =
//           selectedCategory == 'All' ||
//               pet['category'] == selectedCategory;

//       final bool searchMatch =
//           searchText.isEmpty ||
//               pet['name']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText) ||
//               pet['breed']
//                   .toString()
//                   .toLowerCase()
//                   .contains(searchText);

//       return categoryMatch && searchMatch;
//     }).toList();

//     if (filteredPets.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       children: filteredPets.map((pet) {
//         return Padding(
//           padding: const EdgeInsets.only(
//             bottom: 14,
//           ),
//           child: _buildPetCard(pet),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // PET CARD
//   // ============================================================

//   Widget _buildPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     final bool isAvailable =
//         pet['status'] == 'Available';

//     return GestureDetector(
//       onTap: () {
//         _showPetDetails(pet);
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: const Color(0xFFDCE7EA),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.035),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           children: [
//             // ==================================================
//             // IMAGE
//             // ==================================================

//             AspectRatio(
//               // IMPORTANT:
//               // The old version used height: 128.
//               // This gives the image a taller frame so the
//               // pet does not look zoomed/cropped.
//               aspectRatio: 1.55,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // ==================================================
//                   // PET IMAGE
//                   // ==================================================

//                   Image.network(
//                     pet['image'].toString(),
//                     fit: BoxFit.cover,
//                     alignment: Alignment.center,
//                     errorBuilder:
//                         (_, __, ___) {
//                       return Container(
//                         color:
//                             const Color(0xFFE9EEF0),
//                         child: Icon(
//                           pet['category'] ==
//                                   'Dogs'
//                               ? Icons.pets
//                               : Icons.cruelty_free,
//                           color: primaryColor,
//                           size: 55,
//                         ),
//                       );
//                     },
//                   ),

//                   // ==================================================
//                   // BOTTOM GRADIENT
//                   // ==================================================

//                   Positioned.fill(
//                     child: DecoratedBox(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin:
//                               Alignment.topCenter,
//                           end:
//                               Alignment.bottomCenter,
//                           stops: const [
//                             0.45,
//                             1.0,
//                           ],
//                           colors: [
//                             Colors.transparent,
//                             Colors.black
//                                 .withOpacity(0.72),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ==================================================
//                   // STATUS
//                   // ==================================================

//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: Container(
//                       padding:
//                           const EdgeInsets.symmetric(
//                         horizontal: 11,
//                         vertical: 7,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isAvailable
//                             ? tealColor
//                             : pendingColor,
//                         borderRadius:
//                             BorderRadius.circular(
//                           20,
//                         ),
//                       ),
//                       child: Text(
//                         pet['status']
//                             .toString()
//                             .toUpperCase(),
//                         style:
//                             const TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight:
//                               FontWeight.bold,
//                           letterSpacing: 0.2,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ==================================================
//                   // FAVORITE BUTTON
//                   // ==================================================

//                   Positioned(
//                     right: 12,
//                     bottom: 12,
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius:
//                             BorderRadius.circular(
//                           50,
//                         ),
//                         onTap: () {
//                           _showFilterMessage(
//                             '${pet['name']} added to favorites.',
//                           );
//                         },
//                         child: Container(
//                           width: 43,
//                           height: 43,
//                           decoration: BoxDecoration(
//                             color: Colors.white
//                                 .withOpacity(0.88),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons
//                                 .favorite_border_rounded,
//                             size: 25,
//                             color:
//                                 Color(0xFF667477),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ==================================================
//                   // PET INFORMATION
//                   // ==================================================

//                   Positioned(
//                     left: 16,
//                     right: 62,
//                     bottom: 14,
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           pet['name'].toString(),
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight:
//                                 FontWeight.bold,
//                             height: 1.1,
//                           ),
//                         ),

//                         const SizedBox(height: 4),

//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 11,
//                             fontWeight:
//                                 FontWeight.w400,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // PET TAGS
//             // ==================================================

//             Container(
//               width: double.infinity,
//               padding:
//                   const EdgeInsets.fromLTRB(
//                 12,
//                 9,
//                 12,
//                 10,
//               ),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 physics:
//                     const BouncingScrollPhysics(),
//                 child: Row(
//                   children: [
//                     if (pet['vaccinated'] == true)
//                       _buildPetTag(
//                         icon:
//                             Icons.vaccines_rounded,
//                         text: 'Vaccinated',
//                       ),

//                     if (pet['vaccinated'] == true &&
//                         (pet['kidFriendly'] == true ||
//                             pet['energy'] != null))
//                       const SizedBox(width: 6),

//                     if (pet['kidFriendly'] == true)
//                       _buildPetTag(
//                         icon: Icons
//                             .child_friendly_rounded,
//                         text: 'Good w/ Kids',
//                       ),

//                     if (pet['kidFriendly'] == true &&
//                         pet['energy'] != null)
//                       const SizedBox(width: 6),

//                     if (pet['energy'] != null)
//                       _buildPetTag(
//                         icon: Icons.bolt_rounded,
//                         text: pet['energy'],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET TAG
//   // ============================================================

//   Widget _buildPetTag({
//     required IconData icon,
//     required String text,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE9F7F6),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 12,
//             color: tealColor,
//           ),

//           const SizedBox(width: 4),

//           Text(
//             text,
//             style: const TextStyle(
//               color: Color(0xFF34706C),
//               fontSize: 9,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         vertical: 70,
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.search_off_rounded,
//             size: 58,
//             color: primaryColor,
//           ),

//           const SizedBox(height: 14),

//           Text(
//             'No pets found',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),

//           const SizedBox(height: 6),

//           const Text(
//             'Try another search or category.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 13,
//             ),
//           ),

//           const SizedBox(height: 18),

//           OutlinedButton(
//             onPressed: () {
//               setState(() {
//                 selectedCategory = 'All';
//                 _searchController.clear();
//               });
//             },
//             style: OutlinedButton.styleFrom(
//               foregroundColor: primaryColor,
//               side: BorderSide(
//                 color: primaryColor,
//               ),
//               shape:
//                   RoundedRectangleBorder(
//                 borderRadius:
//                     BorderRadius.circular(20),
//               ),
//             ),
//             child: const Text(
//               'Clear Filters',
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PET DETAILS
//   // ============================================================

//   void _showPetDetails(
//     Map<String, dynamic> pet,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(25),
//         ),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   // HANDLE
//                   Center(
//                     child: Container(
//                       width: 42,
//                       height: 4,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius:
//                             BorderRadius.circular(5),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 18),

//                   // IMAGE
//                   ClipRRect(
//                     borderRadius:
//                         BorderRadius.circular(18),
//                     child: AspectRatio(
//                       aspectRatio: 1.45,
//                       child: Image.network(
//                         pet['image'].toString(),
//                         fit: BoxFit.cover,
//                         alignment: Alignment.center,
//                         errorBuilder:
//                             (_, __, ___) {
//                           return Container(
//                             color:
//                                 const Color(0xFFE9EEF0),
//                             child: Icon(
//                               Icons.pets,
//                               size: 60,
//                               color: primaryColor,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 18),

//                   // NAME
//                   Text(
//                     pet['name'].toString(),
//                     style: TextStyle(
//                       color: darkText,
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 5),

//                   // DETAILS
//                   Text(
//                     '${pet['breed']} • ${pet['age']} • ${pet['gender']}',
//                     style: const TextStyle(
//                       color: Colors.grey,
//                       fontSize: 14,
//                     ),
//                   ),

//                   const SizedBox(height: 14),

//                   // STATUS
//                   Row(
//                     children: [
//                       Container(
//                         padding:
//                             const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color:
//                               pet['status'] ==
//                                       'Available'
//                                   ? const Color(
//                                       0xFFE3F6F3,
//                                     )
//                                   : const Color(
//                                       0xFFF8E9E2,
//                                     ),
//                           borderRadius:
//                               BorderRadius.circular(
//                             15,
//                           ),
//                         ),
//                         child: Text(
//                           pet['status']
//                               .toString()
//                               .toUpperCase(),
//                           style: TextStyle(
//                             color:
//                                 pet['status'] ==
//                                         'Available'
//                                     ? tealColor
//                                     : pendingColor,
//                             fontSize: 10,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 14),

//                   // TAGS
//                   Wrap(
//                     spacing: 6,
//                     runSpacing: 6,
//                     children: [
//                       if (pet['vaccinated'] == true)
//                         _buildPetTag(
//                           icon:
//                               Icons.vaccines_rounded,
//                           text: 'Vaccinated',
//                         ),

//                       if (pet['kidFriendly'] == true)
//                         _buildPetTag(
//                           icon: Icons
//                               .child_friendly_rounded,
//                           text: 'Good with Kids',
//                         ),

//                       if (pet['energy'] != null)
//                         _buildPetTag(
//                           icon: Icons.bolt_rounded,
//                           text: pet['energy'],
//                         ),
//                     ],
//                   ),

//                   const SizedBox(height: 24),

//                   // ADOPTION BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);

//                         _showFilterMessage(
//                           'Adoption request coming soon.',
//                         );
//                       },
//                       style:
//                           ElevatedButton.styleFrom(
//                         backgroundColor:
//                             primaryColor,
//                         foregroundColor:
//                             Colors.white,
//                         elevation: 0,
//                         shape:
//                             RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(
//                             26,
//                           ),
//                         ),
//                       ),
//                       child: const Text(
//                         'View Adoption Details',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight:
//                               FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 5),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // FILTER DIALOG
//   // ============================================================

//   void _showFilterDialog({
//     required String title,
//     required List<String> options,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(22),
//         ),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(
//               20,
//               16,
//               20,
//               20,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius:
//                           BorderRadius.circular(5),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 Text(
//                   'Filter by $title',
//                   style: TextStyle(
//                     color: darkText,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 ...options.map(
//                   (option) {
//                     return ListTile(
//                       contentPadding:
//                           EdgeInsets.zero,
//                       title: Text(
//                         option,
//                         style: TextStyle(
//                           color: darkText,
//                           fontSize: 14,
//                         ),
//                       ),
//                       trailing: const Icon(
//                         Icons.chevron_right_rounded,
//                         color: Colors.grey,
//                       ),
//                       onTap: () {
//                         Navigator.pop(context);

//                         _showFilterMessage(
//                           '$title: $option',
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showFilterMessage(
//     String message,
//   ) {
//     ScaffoldMessenger.of(context)
//         .hideCurrentSnackBar();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior:
//             SnackBarBehavior.floating,
//         duration:
//             const Duration(seconds: 2),
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';

// class PetsScreen extends StatefulWidget {
//   const PetsScreen({super.key});

//   @override
//   State<PetsScreen> createState() => _PetsScreenState();
// }

// class _PetsScreenState extends State<PetsScreen> {
//   // ============================================================
//   // COLORS
//   // ============================================================

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   // ============================================================
//   // FILTER
//   // ============================================================

//   String selectedCategory = 'All';

//   final List<String> categories = [
//     'All',
//     'Dogs',
//     'Cats',
//   ];

//   // ============================================================
//   // PET DATA
//   // ============================================================

//   final List<Map<String, dynamic>> pets = [
//     {
//       'name': 'Bella',
//       'breed': 'Golden Retriever',
//       'age': '2 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': true,
//       'energy': 'High Energy',
//       'image':
//           'https://images.unsplash.com/photo-1552053831-71594a27632d?w=800',
//       'category': 'Dogs',
//     },
//     {
//       'name': 'Oliver',
//       'breed': 'Domestic Longhair',
//       'age': '4 yrs',
//       'gender': 'Male',
//       'status': 'Pending',
//       'vaccinated': true,
//       'kidFriendly': true,
//       'energy': 'Calm',
//       'image':
//           'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800',
//       'category': 'Cats',
//     },
//     {
//       'name': 'Scout',
//       'breed': 'Terrier Mix',
//       'age': '1 yr',
//       'gender': 'Male',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'High Energy',
//       'image':
//           'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
//       'category': 'Dogs',
//     },
//     {
//       'name': 'Luna',
//       'breed': 'Calico',
//       'age': '3 yrs',
//       'gender': 'Female',
//       'status': 'Available',
//       'vaccinated': true,
//       'kidFriendly': false,
//       'energy': 'Indoor Only',
//       'image':
//           'https://images.unsplash.com/photo-1519052537078-e6302a4968d4?w=800',
//       'category': 'Cats',
//     },
//   ];

//   // ============================================================
//   // BUILD
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: backgroundColor,
//       child: Column(
//         children: [
//           _buildHeader(),

//           Expanded(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               padding: const EdgeInsets.fromLTRB(
//                 12,
//                 8,
//                 12,
//                 20,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSearchBar(),

//                   const SizedBox(height: 10),

//                   _buildCategoryFilter(),

//                   const SizedBox(height: 8),

//                   _buildFilterButtons(),

//                   const SizedBox(height: 12),

//                   _buildPetList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // HEADER
//   // ============================================================

//   Widget _buildHeader() {
//     return Container(
//       height: 58,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Color(0xFFE5E5E5),
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // PROFILE IMAGE
//           Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: const Color(0xFFE0E0E0),
//               ),
//               image: const DecorationImage(
//                 image: NetworkImage(
//                   'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
//                 ),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           const SizedBox(width: 9),

//           // TITLE
//           Expanded(
//             child: Text(
//               'My Future Pet',
//               style: TextStyle(
//                 color: primaryColor,
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),

//           // SEARCH ICON
//           IconButton(
//             onPressed: () {},
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(
//               minWidth: 30,
//               minHeight: 30,
//             ),
//             icon: Icon(
//               Icons.search_rounded,
//               color: darkText,
//               size: 17,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // SEARCH BAR
//   // ============================================================

//   Widget _buildSearchBar() {
//     return Container(
//       height: 34,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: TextField(
//         style: TextStyle(
//           color: darkText,
//           fontSize: 10,
//         ),
//         decoration: InputDecoration(
//           hintText: 'Search by name or breed',
//           hintStyle: const TextStyle(
//             color: Color(0xFF999999),
//             fontSize: 9,
//           ),
//           prefixIcon: const Icon(
//             Icons.search_rounded,
//             size: 15,
//             color: Color(0xFF8B8B8B),
//           ),
//           prefixIconConstraints: const BoxConstraints(
//             minWidth: 34,
//           ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 9,
//           ),
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // CATEGORY FILTER
//   // ============================================================

//   Widget _buildCategoryFilter() {
//     return Row(
//       children: categories.map((category) {
//         final bool selected =
//             selectedCategory == category;

//         return Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 3,
//             ),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedCategory = category;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration:
//                     const Duration(milliseconds: 180),
//                 height: 28,
//                 decoration: BoxDecoration(
//                   color: selected
//                       ? primaryColor
//                       : const Color(0xFFE7F5FA),
//                   borderRadius:
//                       BorderRadius.circular(16),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   category,
//                   style: TextStyle(
//                     color: selected
//                         ? Colors.white
//                         : darkText,
//                     fontSize: 9,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // FILTER BUTTONS
//   // ============================================================

//   Widget _buildFilterButtons() {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Breed',
//             icon: Icons.keyboard_arrow_down_rounded,
//             onTap: () {
//               _showFilterMessage('Breed filter');
//             },
//           ),
//         ),

//         const SizedBox(width: 5),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Age',
//             icon: Icons.keyboard_arrow_down_rounded,
//             onTap: () {
//               _showFilterMessage('Age filter');
//             },
//           ),
//         ),

//         const SizedBox(width: 5),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Gender',
//             icon: Icons.keyboard_arrow_down_rounded,
//             onTap: () {
//               _showFilterMessage('Gender filter');
//             },
//           ),
//         ),

//         const SizedBox(width: 5),

//         Expanded(
//           child: _buildSmallFilter(
//             label: 'Status',
//             icon: Icons.keyboard_arrow_down_rounded,
//             onTap: () {
//               _showFilterMessage('Status filter');
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSmallFilter({
//     required String label,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 25,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(5),
//           border: Border.all(
//             color: const Color(0xFFDCE5E8),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: darkText,
//                 fontSize: 7.5,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Icon(
//               icon,
//               size: 11,
//               color: const Color(0xFF6D777B),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET LIST
//   // ============================================================

//   Widget _buildPetList() {
//     final List<Map<String, dynamic>> filteredPets =
//         selectedCategory == 'All'
//             ? pets
//             : pets
//                 .where(
//                   (pet) =>
//                       pet['category'] ==
//                       selectedCategory,
//                 )
//                 .toList();

//     if (filteredPets.isEmpty) {
//       return _buildEmptyState();
//     }

//     return Column(
//       children: filteredPets.map((pet) {
//         return Padding(
//           padding: const EdgeInsets.only(
//             bottom: 10,
//           ),
//           child: _buildPetCard(pet),
//         );
//       }).toList(),
//     );
//   }

//   // ============================================================
//   // PET CARD
//   // ============================================================

//   Widget _buildPetCard(
//     Map<String, dynamic> pet,
//   ) {
//     final bool isAvailable =
//         pet['status'] == 'Available';

//     return GestureDetector(
//       onTap: () {
//         _showPetDetails(pet);
//       },
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(9),
//           border: Border.all(
//             color: const Color(0xFFDDE8EC),
//           ),
//         ),
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           children: [
//             // ==================================================
//             // IMAGE
//             // ==================================================

//             SizedBox(
//               height: 128,
//               width: double.infinity,
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: Image.network(
//                       pet['image'],
//                       fit: BoxFit.cover,
//                       errorBuilder:
//                           (_, __, ___) {
//                         return Container(
//                           color:
//                               const Color(0xFFE9EEF0),
//                           child: Icon(
//                             pet['category'] ==
//                                     'Dogs'
//                                 ? Icons.pets
//                                 : Icons
//                                     .cruelty_free,
//                             color: primaryColor,
//                             size: 50,
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   // DARK GRADIENT
//                   Positioned.fill(
//                     child: DecoratedBox(
//                       decoration: BoxDecoration(
//                         gradient:
//                             LinearGradient(
//                           begin:
//                               Alignment.topCenter,
//                           end:
//                               Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black
//                                 .withOpacity(
//                               0.7,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   // STATUS
//                   Positioned(
//                     top: 7,
//                     right: 7,
//                     child: Container(
//                       padding:
//                           const EdgeInsets
//                               .symmetric(
//                         horizontal: 7,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isAvailable
//                             ? const Color(
//                                 0xFF008F82,
//                               )
//                             : const Color(
//                                 0xFFB65C32,
//                               ),
//                         borderRadius:
//                             BorderRadius.circular(
//                           10,
//                         ),
//                       ),
//                       child: Text(
//                         pet['status']
//                             .toString()
//                             .toUpperCase(),
//                         style:
//                             const TextStyle(
//                           color: Colors.white,
//                           fontSize: 6,
//                           fontWeight:
//                               FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // FAVORITE
//                   Positioned(
//                     right: 7,
//                     bottom: 7,
//                     child: Container(
//                       width: 23,
//                       height: 23,
//                       decoration: BoxDecoration(
//                         color: Colors.white
//                             .withOpacity(0.7),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons
//                             .favorite_border_rounded,
//                         size: 14,
//                         color: Color(0xFF526069),
//                       ),
//                     ),
//                   ),

//                   // PET INFORMATION
//                   Positioned(
//                     left: 8,
//                     right: 35,
//                     bottom: 7,
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           pet['name'],
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 13,
//                             fontWeight:
//                                 FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 1),
//                         Text(
//                           '${pet['breed']} • ${pet['age']}',
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.ellipsis,
//                           style:
//                               const TextStyle(
//                             color: Colors.white,
//                             fontSize: 7,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ==================================================
//             // PET TAGS
//             // ==================================================

//             Padding(
//               padding: const EdgeInsets.fromLTRB(
//                 8,
//                 5,
//                 8,
//                 6,
//               ),
//               child: Row(
//                 children: [
//                   if (pet['vaccinated'] == true)
//                     _buildPetTag(
//                       icon: Icons
//                           .vaccines_rounded,
//                       text: 'Vaccinated',
//                     ),

//                   if (pet['vaccinated'] == true)
//                     const SizedBox(width: 4),

//                   if (pet['kidFriendly'] == true)
//                     _buildPetTag(
//                       icon: Icons
//                           .child_friendly_rounded,
//                       text: 'Good with Kids',
//                     ),

//                   if (pet['kidFriendly'] == true)
//                     const SizedBox(width: 4),

//                   if (pet['energy'] != null)
//                     _buildPetTag(
//                       icon: Icons.bolt_rounded,
//                       text: pet['energy'],
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ============================================================
//   // PET TAG
//   // ============================================================

//   Widget _buildPetTag({
//     required IconData icon,
//     required String text,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 6,
//         vertical: 3,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE9F7F6),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 8,
//             color: const Color(0xFF008F82),
//           ),
//           const SizedBox(width: 2),
//           Text(
//             text,
//             style: const TextStyle(
//               color: Color(0xFF34706C),
//               fontSize: 6.5,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // EMPTY STATE
//   // ============================================================

//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(
//         vertical: 60,
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.search_off_rounded,
//             size: 50,
//             color: primaryColor,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'No pets found',
//             style: TextStyle(
//               color: darkText,
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 5),
//           const Text(
//             'Try selecting another category.',
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ============================================================
//   // PET DETAILS
//   // ============================================================

//   void _showPetDetails(
//     Map<String, dynamic> pet,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(25),
//         ),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment:
//                   CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius:
//                           BorderRadius.circular(5),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 18),

//                 ClipRRect(
//                   borderRadius:
//                       BorderRadius.circular(15),
//                   child: Image.network(
//                     pet['image'],
//                     width: double.infinity,
//                     height: 200,
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 Text(
//                   pet['name'],
//                   style: TextStyle(
//                     color: darkText,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 5),

//                 Text(
//                   '${pet['breed']} • ${pet['age']} • ${pet['gender']}',
//                   style: const TextStyle(
//                     color: Colors.grey,
//                     fontSize: 13,
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 Row(
//                   children: [
//                     if (pet['vaccinated'] == true)
//                       _buildPetTag(
//                         icon:
//                             Icons.vaccines_rounded,
//                         text: 'Vaccinated',
//                       ),
//                     const SizedBox(width: 5),
//                     if (pet['kidFriendly'] == true)
//                       _buildPetTag(
//                         icon: Icons
//                             .child_friendly_rounded,
//                         text: 'Good with Kids',
//                       ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _showFilterMessage(
//                         'Adoption request coming soon.',
//                       );
//                     },
//                     style:
//                         ElevatedButton.styleFrom(
//                       backgroundColor:
//                           primaryColor,
//                       foregroundColor:
//                           Colors.white,
//                       elevation: 0,
//                       shape:
//                           RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(
//                           25,
//                         ),
//                       ),
//                     ),
//                     child: const Text(
//                       'View Adoption Details',
//                       style: TextStyle(
//                         fontWeight:
//                             FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ============================================================
//   // MESSAGE
//   // ============================================================

//   void _showFilterMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';

// class PetsScreen extends StatelessWidget {
//   const PetsScreen({super.key});

//   final Color primaryColor = const Color(0xFFA94327);
//   final Color backgroundColor = const Color(0xFFF5FAFD);
//   final Color darkText = const Color(0xFF062B35);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         title: Text(
//           'Pets',
//           style: TextStyle(
//             color: darkText,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: const Center(
//         child: Text(
//           'Browse pets available for adoption.',
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 15,
//           ),
//         ),
//       ),
//     );
//   }
// }
