import 'dart:io';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:event/constants/styles.dart';
import 'package:event/utils/appManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FinalRegister extends StatefulWidget {
  FinalRegister({Key? key, required this.title, required this.appManager})
      : super(key: key);

  final String title;
  final AppManager appManager;

  @override
  _FinalRegisterState createState() => _FinalRegisterState();
}

class _FinalRegisterState extends State<FinalRegister> {
    late SharedPreferences prefs;
      String email = '';


  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  TextEditingController _locationController = TextEditingController();
  TextEditingController _fnameController = TextEditingController();
  TextEditingController _lnameController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _companyController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _multiLineController = TextEditingController();
  int _characterCount = 0;

  static const kGoogleApiKey = "AIzaSyB7d4yI7ZmAGjDVpQHYM-aNo_UlfNCHtdk";
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  List<bool> isError = [
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  bool isValidForm() {
    isError.clear();
    isError = [
      false,
      false,
      false,
      false,
      false,
      false,
    ];
    if (_fnameController.text == '') {
      showToast('Please enter first name', 2, kToastColor, this.context);
      setState(() {
        isError[0] = true;
      });
      return false;
    } else if (_lnameController.text == '') {
      showToast('Please enter last name', 2, kToastColor, this.context);
      setState(() {
        isError[1] = true;
      });
      return false;
    
    } else if (_locationController.text == '') {
      showToast('Please select location', 2, kToastColor, this.context);
      setState(() {
        isError[4] = true;
      });
      return false;
    } else if (_mobileController.text.length < 10) {
      showToast('please enter valid mobile number', 2, kToastColor, this.context);
      setState(() {
        isError[5] = true;
      });
      return false;
    } else {
      print("Proceed");
      FocusScope.of(this.context).unfocus();
      return true;
    }
  }

  void showToast(
      String msg, int duration, Color bgColor, BuildContext context) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: duration,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _pickFromCamera() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _pickImages(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    setState(() {
      _image = selectedImage;
    });
  }

  Future<void> _showImagePickerDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user can tap outside to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Upload Photo',
            style: kNamePainStyle,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text(
                    'Camera',
                    style: kNamePainStyle,
                  ),
                  onTap: () {
                    _pickFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text(
                    'Gallery',
                    style: kNamePainStyle,
                  ),
                  onTap: () {
                    _pickImage();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> displayPrediction(Prediction p, BuildContext context) async {
    if (p.placeId != null) {
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(p.description!),
              content: Text("Latitude: $lat, Longitude: $lng"),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      showToast('Please select an image',
       2, Colors.red, this.context);
      return;
    }

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse('https://app.ewomennetwork.com/ewomen/api/register'));

    // Add headers if needed
    request.headers.addAll({
      'Authorization': 'Bearer YOUR_TOKEN',
      'Content-Type': 'multipart/form-data',
    });

    // Add the image file to the request
    File imageFile = File(_image!.path);
    var mimeTypeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8])?.split('/');
    request.files.add(http.MultipartFile(
      'image', // Parameter name expected by the server
      imageFile.readAsBytes().asStream(),
      imageFile.lengthSync(),
      filename: basename(imageFile.path),
      contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
    ));

    // Add other form fields if needed
    request.fields['first_name'] = _fnameController.text;
    request.fields['last_name'] = _lnameController.text;
    request.fields['location'] = _locationController.text;
    request.fields['phone'] = _mobileController.text;
    request.fields['title'] = _titleController.text;
    request.fields['company'] = _companyController.text;
    request.fields['description'] = _multiLineController.text;
    request.fields['email'] = email;
    request.fields['password'] = "123456";
    request.fields['confirm_password'] = "123456";
    request.fields['latitude'] = "22.987";
    request.fields['longitude'] = "77.0987";

    print(request);

    // Send the request
    var response = await request.send();
    print(response);

    // Handle the response
    if (response.statusCode == 200) {
      showToast('Image uploaded successfully', 2,
       Colors.green, this.context);
    } else {
      showToast('Image upload failed with status: ${response.statusCode}',
       2, Colors.red, this.context);
    }
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _multiLineController.text.length;
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrefs();
  }

  getPrefs() async {
    this.prefs = await SharedPreferences.getInstance();
    this.email = prefs.getString('email') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: topHeaderBar,
        surfaceTintColor: topHeaderBar,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Signup',
          style: kHeaderTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 10),
          color: backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image == null
                  ? ClipOval(
                      child: Image.asset('assets/businessman.png',
                          height: 80, width: 80, fit: BoxFit.cover),
                    )
                  : ClipOval(
                      child: Image.file(File(_image!.path),
                          height: 80, width: 80, fit: BoxFit.cover),
                    ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  _showImagePickerDialog(context);
                },
                child: Text(
                  'Upload Photo',
                  style: kAlertButtonTextStyle,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kLoginTextFieldFillColor,
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_2_outlined,
                        size: 20, color: kLoginIconColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _fnameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'First Name*',
                          hintStyle: kLoginTextFieldTextStyle,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kLoginTextFieldFillColor,
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_2_outlined,
                        size: 20, color: kLoginIconColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lnameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'Last Name*',
                          hintStyle: kLoginTextFieldTextStyle,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kLoginTextFieldFillColor,
                ),
                child: Row(
                  children: [
                    Icon(Icons.title_outlined,
                        size: 20, color: kLoginIconColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'Title',
                          hintStyle: kLoginTextFieldTextStyle,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kLoginTextFieldFillColor,
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_business, size: 20, color: kLoginIconColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _companyController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'Company',
                          hintStyle: kLoginTextFieldTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kLoginTextFieldFillColor,
                ),
                child: Row(
                  children: [
                    Icon(Icons.pin_drop, size: 20, color: kLoginIconColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        readOnly: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'Your location*',
                          hintStyle: kLoginTextFieldTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kLoginTextFieldFillColor,
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 20, color: kLoginIconColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _mobileController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          hintText: 'Mobile Number*',
                          hintStyle: kLoginTextFieldTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kLoginTextFieldFillColor,
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 20, color: kLoginIconColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _multiLineController,
                        maxLength: 250,
                        maxLines: null,
                        onChanged: (text) => _updateCharacterCount(),
                        decoration: InputDecoration(
                          hintText:
                              'Tell us more about yourself! Who are you? Who are you trying to connect with?',
                          hintStyle: kLoginTextFieldTextStyle,
                          hintMaxLines: 3,
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: size.width,
                height: 65,
                margin: EdgeInsets.only(bottom: 30, top: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: kButtonColor,
                  ),
                  child: Text('SignUp', style: kButtonTextStyle),
                  onPressed: () async {
                    if (isValidForm()) {
                      await _uploadImage();
                      //Navigator.pushReplacementNamed(context, '/home', arguments: false);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
