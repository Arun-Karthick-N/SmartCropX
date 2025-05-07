import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final supabase = Supabase.instance.client;

class ScheduledCropsPage extends StatefulWidget {
  @override
  _ScheduledCropsPageState createState() => _ScheduledCropsPageState();
}

class _ScheduledCropsPageState extends State<ScheduledCropsPage> {
  List<Map<String, dynamic>> _scheduledCrops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchScheduledCrops();
  }

  Future<void> _fetchScheduledCrops() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No authenticated user found. Please log in.');
      }

      final response = await supabase
          .from('crop_scheduling')
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: true);

      setState(() {
        _scheduledCrops = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching scheduled crops: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCrop(
      BuildContext context, Map<String, dynamic> crop) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete the crop schedule for ${crop['crop_name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final userId = supabase.auth.currentUser?.id;
        if (userId == null) {
          throw Exception('User not authenticated');
        }

        await supabase.from('crop_scheduling').delete().match({
          'user_id': userId,
          'start_date': crop['start_date'],
        });

        _fetchScheduledCrops(); // Refresh the list after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Crop schedule deleted!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting schedule: $e')),
        );
      }
    }
  }

  Future<void> _editCrop(
      BuildContext context, Map<String, dynamic> crop) async {
    final TextEditingController _landSizeController =
    TextEditingController(text: crop['land_size'].toString());
    final TextEditingController _locationController =
    TextEditingController(text: crop['state'] ?? ''); // Use state instead
    String _landUnit = crop['land_unit'];
    String _cropType = crop['crop_type'];
    String? _cropName = crop['crop_name'];
    DateTime _startDate = DateTime.parse(crop['start_date']);
    DateTime _endDate = DateTime.parse(crop['end_date']);
    String? _selectedState = crop['state'];
    String? _selectedDistrict = crop['district'];
    final originalStartDate = _startDate;

    final List<String> _landUnits = ['Cents', 'Acres'];
    final Map<String, List<String>> _cropOptions = {
      'Vegetable': ['Tomato', 'Carrot', 'Potato', 'Cabbage', 'Spinach'],
      'Fruit': ['Mango', 'Banana', 'Apple', 'Grapes', 'Orange'],
      'Grain': ['Wheat', 'Rice', 'Corn', 'Barley', 'Millet'],
      'Herb': ['Mint', 'Basil', 'Coriander', 'Thyme', 'Oregano'],
      'Seed': ['Sunflower', 'Sesame', 'Pumpkin', 'Flax', 'Chia'],
      'Nut': ['Almond', 'Cashew', 'Walnut', 'Peanut', 'Pistachio'],
      'Pulse': ['Lentil', 'Chickpea', 'Pea', 'Kidney Bean', 'Black Gram'],
    };

    final Map<String, List<String>> _stateDistricts = {
      'Andhra Pradesh': [
        'Ananthapur',
        'Chittoor',
        'East Godavari',
        'Guntur',
        'Kadapa YSR',
        'Krishna',
        'Kurnool',
        'S.P.S. Nellore',
        'Srikakulam',
        'Visakhapatnam',
        'West Godavari'
      ],
      'Assam': [
        'Cachar',
        'Darrang',
        'Dibrugarh',
        'Goalpara',
        'Kamrup',
        'Karbi Anglong',
        'Lakhimpur',
        'Nagaon',
        'North Cachar Hil / Dima hasao',
        'Sibsagar'
      ],
      'Bihar': [
        'Bhagalpur',
        'Champaran',
        'Darbhanga',
        'Gaya',
        'Mungair',
        'Muzaffarpur',
        'Patna',
        'Purnea',
        'Saharsa',
        'Saran',
        'Shahabad (now part of Bhojpur district)'
      ],
      'Chhattisgarh': [
        'Bastar',
        'Bilaspur',
        'Durg',
        'Raigarh',
        'Raipur',
        'Surguja'
      ],
      'Gujarat': [
        'Ahmedabad',
        'Amreli',
        'Banaskantha',
        'Bharuch',
        'Bhavnagar',
        'Dangs',
        'Jamnagar',
        'Junagadh',
        'Kheda',
        'Kutch',
        'Mehsana',
        'Panchmahal',
        'Rajkot',
        'Sabarkantha',
        'Surat',
        'Surendranagar',
        'Vadodara / Baroda',
        'Valsad'
      ],
      'Haryana': [
        'Ambala',
        'Gurgaon',
        'Hissar',
        'Jind',
        'Karnal',
        'Mahendragarh / Narnaul',
        'Rohtak'
      ],
      'Himachal Pradesh': [
        'Bilashpur',
        'Chamba',
        'Kangra',
        'Kinnaur',
        'Kullu',
        'Lahul & Spiti',
        'Mandi',
        'Shimla',
        'Sirmaur',
        'Solan'
      ],
      'Jharkhand': [
        'Dhanbad',
        'Hazaribagh',
        'Palamau',
        'Ranchi',
        'Santhal Paragana / Dumka',
        'Singhbhum'
      ],
      'Karnataka': [
        'Bangalore',
        'Belgaum',
        'Bellary',
        'Bidar',
        'Bijapur / Vijayapura',
        'Chickmagalur',
        'Chitradurga',
        'Dakshina Kannada',
        'Dharwad',
        'Gulbarga / Kalaburagi',
        'Hassan',
        'Kodagu / Coorg',
        'Kolar',
        'Mandya',
        'Mysore',
        'Raichur',
        'Shimoge',
        'Tumkur',
        'Uttara Kannada'
      ],
      'Kerala': [
        'Alappuzha',
        'Eranakulam',
        'Kannur',
        'Kollam',
        'Kottayam',
        'Kozhikode',
        'Malappuram',
        'Palakkad',
        'Thiruvananthapuram',
        'Thrissur'
      ],
      'Madhya Pradesh': [
        'Balaghat',
        'Betul',
        'Bhind',
        'Chhatarpur',
        'Chhindwara',
        'Damoh',
        'Datia',
        'Dewas',
        'Dhar',
        'Guna',
        'Gwalior',
        'Hoshangabad',
        'Indore',
        'Jabalpur',
        'Jhabua',
        'Khandwa / East Nimar',
        'Khargone / West Nimar',
        'Mandla',
        'Mandsaur',
        'Morena',
        'Narsinghpur',
        'Panna',
        'Raisen',
        'Rajgarh',
        'Ratlam',
        'Rewa',
        'Sagar',
        'Satna',
        'Sehore',
        'Seoni / Shivani',
        'Shahdol',
        'Shajapur',
        'Shivpuri',
        'Sidhi',
        'Tikamgarh',
        'Ujjain',
        'Vidisha'
      ],
      'Maharashtra': [
        'Ahmednagar',
        'Akola',
        'Amarawati',
        'Aurangabad',
        'Beed',
        'Bhandara',
        'Bombay',
        'Buldhana',
        'Chandrapur',
        'Dhule',
        'Jalgaon',
        'Kolhapur',
        'Nagpur',
        'Nanded',
        'Nasik',
        'Osmanabad',
        'Parbhani',
        'Pune',
        'Raigad',
        'Ratnagiri',
        'Sangli',
        'Satara',
        'Solapur',
        'Thane',
        'Wardha',
        'Yeotmal'
      ],
      'Orissa': [
        'Balasore',
        'Bolangir',
        'Cuttack',
        'Dhenkanal',
        'Ganjam',
        'Kalahandi',
        'Keonjhar',
        'Koraput',
        'Mayurbhanja',
        'Phulbani ( Kandhamal )',
        'Puri',
        'Sambalpur',
        'Sundargarh'
      ],
      'Punjab': [
        'Amritsar',
        'Bhatinda',
        'Ferozpur',
        'Gurdaspur',
        'Hoshiarpur',
        'Jalandhar',
        'Kapurthala',
        'Ludhiana',
        'Patiala',
        'Roopnagar / Ropar',
        'Sangrur'
      ],
      'Rajasthan': [
        'Ajmer',
        'Alwar',
        'Banswara',
        'Barmer',
        'Bharatpur',
        'Bhilwara',
        'Bikaner',
        'Bundi',
        'Chittorgarh',
        'Churu',
        'Dungarpur',
        'Ganganagar',
        'Jaipur',
        'Jaisalmer',
        'Jalore',
        'Jhalawar',
        'Jhunjhunu',
        'Jodhpur',
        'Kota',
        'Nagaur',
        'Pali',
        'Sikar',
        'Sirohi',
        'Swami Madhopur',
        'Tonk',
        'Udaipur'
      ],
      'Tamil Nadu': [
        'Chengalpattu MGR / Kanchipuram',
        'Coimbatore',
        'Kanyakumari',
        'Madurai',
        'North Arcot / Vellore',
        'Ramananthapuram',
        'Salem',
        'South Arcot / Cuddalore',
        'Thanjavur',
        'The Nilgiris',
        'Thirunelveli',
        'Tiruchirapalli / Trichy'
      ],
      'Telangana': [
        'Adilabad',
        'Hyderabad',
        'Karimnagar',
        'Khammam',
        'Mahabubnagar',
        'Medak',
        'Nalgonda',
        'Nizamabad',
        'Warangal'
      ],
      'Uttar Pradesh': [
        'Agra',
        'Aligarh',
        'Allahabad',
        'Azamgarh',
        'Bahraich',
        'Ballia',
        'Banda',
        'Barabanki',
        'Bareilly',
        'Basti',
        'Bijnor',
        'Budaun',
        'Buland Shahar',
        'Deoria',
        'Etah',
        'Etawah',
        'Faizabad',
        'Farrukhabad',
        'Fatehpur',
        'Ghazipur',
        'Gonda',
        'Gorakhpur',
        'Hamirpur',
        'Hardoi',
        'Jalaun',
        'Jaunpur',
        'Jhansi',
        'Kanpur',
        'Kheri',
        'Lucknow',
        'Mainpuri',
        'Mathura',
        'Meerut',
        'Mirzpur',
        'Moradabad',
        'Muzaffarnagar',
        'Pilibhit',
        'Pratapgarh',
        'Rae-Bareily',
        'Rampur',
        'Saharanpur',
        'Shahjahanpur',
        'Sitapur',
        'Sultanpur',
        'Unnao',
        'Varanasi'
      ],
      'Uttarakhand': [
        'Almorah',
        'Chamoli',
        'Dehradun',
        'Garhwal',
        'Nainital',
        'Pithorgarh',
        'Tehri Garhwal',
        'Uttar Kashi'
      ],
      'West Bengal': [
        '24 Parganas',
        'Bankura',
        'Birbhum',
        'Burdwan',
        'Cooch Behar',
        'Darjeeling',
        'Hooghly',
        'Howrah',
        'Jalpaiguri',
        'Malda',
        'Midnapur',
        'Murshidabad',
        'Nadia',
        'Purulia',
        'West Dinajpur'
      ],
    };

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Crop Schedule'),
              content: SingleChildScrollView(
                padding: EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 280,
                        child: DropdownButtonFormField<String>(
                          isExpanded:
                          true, // Ensure it fills the available width
                          decoration: InputDecoration(labelText: 'Land Unit'),
                          value: _landUnit,
                          items: _landUnits
                              .map((unit) => DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _landUnit = value!),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 280,
                        child: TextFormField(
                          controller: _landSizeController,
                          decoration: InputDecoration(labelText: 'Land Size'),
                          keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                          validator: (value) =>
                          value!.isEmpty || double.tryParse(value) == null
                              ? 'Enter a valid number'
                              : null,
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 280,
                        child: DropdownButtonFormField<String>(
                          isExpanded:
                          true, // Ensure it fills the available width
                          decoration: InputDecoration(labelText: 'Crop Type'),
                          value: _cropType,
                          items: _cropOptions.keys
                              .map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ))
                              .toList(),
                          onChanged: (value) => setState(() {
                            _cropType = value!;
                            _cropName = null;
                          }),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 280,
                        child: DropdownButtonFormField<String>(
                          isExpanded:
                          true, // Ensure it fills the available width
                          decoration: InputDecoration(labelText: 'Crop Name'),
                          value: _cropName,
                          items: _cropOptions[_cropType]!
                              .map((crop) => DropdownMenuItem<String>(
                            value: crop,
                            child: Text(crop),
                          ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _cropName = value),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 280,
                        child: DropdownButtonFormField<String>(
                          isExpanded:
                          true, // Ensure it fills the available width
                          decoration: InputDecoration(labelText: 'State'),
                          value: _selectedState,
                          items: _stateDistricts.keys
                              .map((state) => DropdownMenuItem<String>(
                            value: state,
                            child: Text(state),
                          ))
                              .toList(),
                          onChanged: (value) => setState(() {
                            _selectedState = value;
                            _selectedDistrict = null;
                          }),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 280,
                        child: DropdownButtonFormField<String>(
                          isExpanded:
                          true, // Ensure it fills the available width
                          decoration: InputDecoration(labelText: 'District'),
                          value: _selectedDistrict,
                          items: _selectedState == null
                              ? []
                              : _stateDistricts[_selectedState]!
                              .map((district) => DropdownMenuItem<String>(
                            value: district,
                            child: Text(
                              district,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedDistrict = value),
                        ),
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        title: Text(
                            'Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                      ),
                      ListTile(
                        title: Text(
                            'End Date: ${DateFormat('yyyy-MM-dd').format(_endDate)}'),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _endDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_endDate.isBefore(_startDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('End date must be after start date')),
                      );
                      return;
                    }
                    try {
                      final userId = supabase.auth.currentUser?.id;
                      if (userId == null) {
                        throw Exception('User not authenticated');
                      }

                      await supabase.from('crop_scheduling').update({
                        'land_size': double.parse(_landSizeController.text),
                        'land_unit': _landUnit,
                        'crop_type': _cropType,
                        'crop_name': _cropName,
                        'state': _selectedState,
                        'district': _selectedDistrict,
                        'start_date': _startDate.toIso8601String(),
                        'end_date': _endDate.toIso8601String(),
                      }).match({
                        'user_id': userId,
                        'start_date': originalStartDate.toIso8601String(),
                      });

                      Navigator.pop(context);
                      _fetchScheduledCrops();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Crop schedule updated!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating schedule: $e')),
                      );
                    }
                  },
                  child: Text('Save', style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scheduled Crops", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xff000a00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _scheduledCrops.isEmpty
          ? Center(child: Text('No scheduled crops found.'))
          : ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: _scheduledCrops.length,
        itemBuilder: (context, index) {
          final crop = _scheduledCrops[index];
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(
                '${crop['crop_name']} (${crop['crop_type']})',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Land: ${crop['land_size']} ${crop['land_unit']}'),
                  Text('State: ${crop['state']}'),
                  Text('District: ${crop['district']}'),
                  Text(
                      'Start: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(crop['start_date']))}'),
                  Text(
                      'End: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(crop['end_date']))}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editCrop(context, crop),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCrop(context, crop),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/crop_scheduling'),
        child: Icon(Icons.add),
        backgroundColor: Color(0xff065a00),
        foregroundColor: Colors.white,
      ),
    );
  }
}
