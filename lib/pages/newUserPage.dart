import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mywarehouseproject/custom_widgets/logoAppBar.dart';
import 'package:mywarehouseproject/custom_widgets/yesNoAlertDialog.dart';
import 'package:mywarehouseproject/models/user.dart';
import 'package:mywarehouseproject/scoped_models/mainModel.dart';

class NewUserPage extends StatefulWidget {
  final MainModel _model;
  final User userForUpadte;

  NewUserPage(this._model, [this.userForUpadte]);

  @override
  State<StatefulWidget> createState() {
    return _NewUserPageState();
  }
}

class _NewUserPageState extends State<NewUserPage> {
  final TextEditingController _nameTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {
    'name': null,
    'address': null,
    'phone': null,
    'sector': null,
    'adminOrUser': null,
    'rights': null,
    'email': null,
    'password': null,
    'imageFile': null
  };
  List<String> selectedRights;
  String selectedSector;
  String selectedAdminUser;
  File _imageFile;

  @override
  void dispose() {
    _nameTextController.dispose();
    super.dispose();
  }

  @override
  initState() {
    isUserForEdit ? selectedRights = widget.userForUpadte.rights : [];
    isUserForEdit ? _nameTextController.text = widget.userForUpadte.name : "";
    isUserForEdit ? selectedAdminUser = widget.userForUpadte.adminOrUser : null;
    super.initState();
  }

  bool get isUserForEdit {
    if (widget.userForUpadte != null) {
      return true;
    } else {
      return false;
    }
  }

  bool shouldShowRights() {
    if (selectedAdminUser == null || selectedAdminUser == "Admin") {
      return false;
    } else {
      return true;
    }
  }

  Widget _buildNameAndSurenameTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        controller: _nameTextController,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Name and Surename",
          prefixIcon: Icon(Icons.person),
        ),
        validator: (String typed) {
          if (typed.isEmpty || typed.length < 8) {
            return "Name and Surename field shouldn't be empty and should be 8+ characters long.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['name'] = typed;
        },
      ),
    );
  }

  Widget _buildAddressTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        initialValue: isUserForEdit ? widget.userForUpadte.address : "",
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Address",
          prefixIcon: Icon(Icons.home),
        ),
        validator: (String typed) {
          if (typed.isEmpty) {
            return "Address field shouldn't be empty.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['address'] = typed;
        },
      ),
    );
  }

  Widget _buildNumberTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        initialValue: isUserForEdit ? widget.userForUpadte.phone : "",
        keyboardType: TextInputType.phone,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Phone number",
          prefixIcon: Icon(Icons.phone),
        ),
        validator: (String typed) {
          if (typed.isEmpty || typed.length < 8) {
            return "Phone number field shouldn't be empty and should be 8+ characters long.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['phone'] = typed;
        },
      ),
    );
  }

  Widget _buildEmailTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "E-mail",
          prefixIcon: Icon(Icons.email),
        ),
        validator: (String typed) {
          if (typed.isEmpty) {
            return "E-mail field shouldn't be empty.";
          } else if (!RegExp(
                  r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
              .hasMatch(typed)) {
            return "Entered e-mail is invalid.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['email'] = typed;
        },
      ),
    );
  }

  Widget _buildPasswordTextField(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      child: TextFormField(
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          focusColor: Theme.of(context).primaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: "Password",
          prefixIcon: Icon(Icons.vpn_key),
        ),
        validator: (String typed) {
          if (typed.isEmpty || typed.length < 8) {
            return "Password field shouldn't be empty and and should be 8+ characters long.";
          }
          return null;
        },
        onSaved: (String typed) {
          _formData['password'] = typed;
        },
      ),
    );
  }

  Widget _buildSectorPicker() {
    return StreamBuilder(
      stream: widget._model.getSectorsFirestoreStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
                children: <Widget>[CircularProgressIndicator()],
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center),
          );
        } else {
          List<DropdownMenuItem> sectorsList = [];
          for (var i = 0; i < snapshot.data.documents.length; i++) {
            DocumentSnapshot document = snapshot.data.documents[i];
            sectorsList.add(
              DropdownMenuItem(
                child: Text(document['name']),
                value: document.documentID,
              ),
            );
          }
          return Container(
            margin: EdgeInsets.only(left: 15.0, right: 15.0),
            padding: EdgeInsets.only(left: 12.0, right: 15.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0)),
            child: Row(
              children: <Widget>[
                Icon(Icons.work, color: Colors.grey),
                DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton(
                      hint: Text("Choose sector"),
                      value: (isUserForEdit && selectedSector == null)
                          ? widget.userForUpadte.sector
                          : selectedSector,
                      items: sectorsList,
                      onChanged: (sector) {
                        setState(() {
                          selectedSector = sector;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildAdminUserPicker(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RadioButtonGroup(
          picked: selectedAdminUser,
          orientation: GroupedButtonsOrientation.HORIZONTAL,
          padding: EdgeInsets.only(left: 50.0, right: 50.0),
          labels: ["Admin", "User"],
          activeColor: Theme.of(context).primaryColor,
          onSelected: (String selected) {
            setState(() {
              selectedAdminUser = selected;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRightsPicker() {
    return StreamBuilder(
        stream: widget._model.getRightsFirestoreStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                  children: <Widget>[CircularProgressIndicator()],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center),
            );
          } else {
            List<String> rightsList = [];
            for (var i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot document = snapshot.data.documents[i];
              rightsList.add(document['name']);
            }
            return Visibility(
              visible: shouldShowRights(),
              child: Container(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10.0)),
                  height: 300.0,
                  child: SingleChildScrollView(
                    child: CheckboxGroup(
                        checked: selectedRights,
                        checkColor: Theme.of(context).primaryColor,
                        labels: rightsList,
                        onSelected: (List<String> checked) {
                          setState(() {
                            selectedRights = checked;
                          });
                        }),
                  ),
                ),
              ),
            );
          }
        });
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ButtonTheme(
      minWidth: 150.0,
      height: 50.0,
      child: FlatButton(
        child: widget._model.isLoading
            ? CircularProgressIndicator()
            : Text(
                isUserForEdit ? "UPDATE USER" : "ADD NEW USER",
                style: TextStyle(
                    fontSize: 15.0,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        onPressed: () {
          setState(() {
            if (!_formKey.currentState.validate()) {
              return;
            }

            if (selectedSector == null) {
              if (isUserForEdit) {
                selectedSector = widget.userForUpadte.sector;
                _validationSectorError = false;
              } else {
                _validationSectorError = true;
              }
            }

            if (selectedAdminUser == null) {
              if (isUserForEdit) {
                selectedAdminUser = widget.userForUpadte.adminOrUser;
                _validationAdminUserError = false;
              } else {
                _validationAdminUserError = true;
              }
            }

            if (isUserForEdit) {
              if (selectedRights == null) {
                selectedRights = widget.userForUpadte.rights;
              }
            }

            if (!_validationAdminUserError && !_validationSectorError) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      contentTextStyle: TextStyle(
                          color: Theme.of(context).accentColor, fontSize: 20.0),
                      backgroundColor: Theme.of(context).primaryColor,
                      content: _buildWarningForImageAndRights(),
                      actions: <Widget>[
                        FlatButton(
                          child: Text(
                            "No",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Theme.of(context).accentColor),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text(
                            "Yes",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Theme.of(context).accentColor),
                          ),
                          onPressed: () {
                            _formKey.currentState.save();
                            _formData['sector'] = selectedSector;
                            _formData['adminOrUser'] = selectedAdminUser;
                            if (selectedAdminUser == "Admin") {
                              _formData['rights'] = null;
                            } else {
                              _formData['rights'] = selectedRights;
                            }
                            _formData['imageFile'] = _imageFile;
                            if (isUserForEdit) {
                              _submitEditUser(widget._model.updateUser);
                            } else {
                              _submitNewUser(widget._model.addNewUser);
                            }
                          },
                        )
                      ],
                    );
                  });
            }
          });
        },
      ),
    );
  }

  Widget _buildAvatarAndUploadPicture(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15.0, left: 50.0),
          child: _imageFile == null
              ? CircleAvatar(
                  maxRadius: 45.0,
                  backgroundImage: (isUserForEdit &&
                          widget.userForUpadte.imageUrl != "" &&
                          widget.userForUpadte.imageUrl != null)
                      ? NetworkImage(widget.userForUpadte.imageUrl)
                      : AssetImage("assets/Images/default-user-picture.png"),
                  backgroundColor: Colors.white,
                )
              : ClipRRect(
                  child: Image.file(
                    _imageFile,
                    fit: BoxFit.cover,
                    height: 110.0,
                    width: 110.0,
                  ),
                  borderRadius: BorderRadius.circular(60.0),
                ),
        ),
        IconButton(
          icon: Icon(
            Icons.photo_camera,
            color: Colors.grey,
          ),
          padding: EdgeInsets.only(top: 80.0, right: 20.0),
          splashColor: Colors.transparent,
          onPressed: () {
            _openImagePicker(context);
          },
        ),
      ],
    );
  }

  void _getImage(BuildContext context, ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    setState(() {
      _imageFile = image;
    });
    Navigator.pop(context);
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).primaryColor,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 115.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Upload worker image",
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
                Divider(),
                // FlatButton.icon(
                //   textColor: Theme.of(context).accentColor,
                //   label: Text("Use Camera"),
                //   icon: Icon(Icons.add_a_photo),
                //   onPressed: () {
                //     _getImage(context, ImageSource.camera);
                //   },
                // ),
                // SizedBox(
                //   height: 5.0,
                // ),
                FlatButton.icon(
                  textColor: Theme.of(context).accentColor,
                  label: Text("Choose from Gallery"),
                  icon: Icon(Icons.photo_library),
                  onPressed: () {
                    _getImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _submitNewUser(Function addNewUser) async {
    setState(() {
      Navigator.of(context).pop();
    });
    final Map<String, dynamic> addUserResponse = await addNewUser(_formData);

    setState(() {
      if (!addUserResponse['success']) {
        _addNewUserError = true;
        _addNewUserErrorMessage = addUserResponse['message'];
      } else {
        Navigator.pushReplacementNamed(context, '/workers');
      }
    });
  }

  void _submitEditUser(Function updateUser) async {
    setState(() {
      Navigator.of(context).pop();
    });
    final Map<String, dynamic> updateSectorResponse =
        await updateUser(widget.userForUpadte.id, _formData);

    setState(() {
      if (!updateSectorResponse['success']) {
        _addNewUserError = true;
        _addNewUserErrorMessage = updateSectorResponse['message'];
      } else {
        Navigator.pushReplacementNamed(context, '/workers');
      }
    });
  }

  Widget _buildNewUserForm(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildAvatarAndUploadPicture(context),
            Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
              child: Text( isUserForEdit ? "Update ${widget.userForUpadte.name}" :
                "New worker",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildNameAndSurenameTextField(context),
                    SizedBox(height: 10.0),
                    _buildAddressTextField(context),
                    SizedBox(height: 10.0),
                    _buildNumberTextField(context),
                    SizedBox(height: 10.0),
                    _buildSectorPicker(),
                    SizedBox(height: 5.0),
                    _buildSectorError(),
                    SizedBox(height: 10.0),
                    Text(
                      "Rights",
                      style: TextStyle(color: Colors.grey, fontSize: 18.0),
                    ),
                    SizedBox(height: 10.0),
                    _buildAdminUserPicker(context),
                    SizedBox(height: 3.0),
                    _buildAdminUserError(),
                    SizedBox(height: 10.0),
                    Visibility(
                      visible: (selectedAdminUser == null ||
                              selectedAdminUser == "Admin")
                          ? false
                          : true,
                      child: Text(
                        "Select worker rights",
                        style: TextStyle(color: Colors.grey, fontSize: 18.0),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    _buildRightsPicker(),
                    Visibility(
                      visible: (selectedAdminUser == null ||
                              selectedAdminUser == "Admin")
                          ? false
                          : true,
                      child: SizedBox(height: 10.0),
                    ),
                    Visibility(
                      visible: isUserForEdit ? false : true,
                      child: Text(
                        "Worker login credentials",
                        style: TextStyle(color: Colors.grey, fontSize: 18.0),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Visibility(
                      visible: isUserForEdit ? false : true,
                      child: _buildEmailTextField(context),
                    ),
                    SizedBox(height: 10.0),
                    Visibility(
                      visible: isUserForEdit ? false : true,
                      child: _buildPasswordTextField(context),
                    ),
                    SizedBox(height: 10.0),
                    _buildSubmitButton(context),
                    SizedBox(height: 10.0),
                    _buildAddNewUserError(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (!_nameTextController.text.isEmpty) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return isUserForEdit
                        ? YesNoAlertDialog(
                            "Are you sure that you don't want to update this worker and go back?",
                            "/workers")
                        : YesNoAlertDialog(
                            "Are you sure that you want to discard all inputs and go back?",
                            "/main");
                  });
            } else {
              Navigator.of(context).pushReplacementNamed('/main');
            }
          },
        ),
        title: LogoAppBar(),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: _buildNewUserForm(context),
    );
  }

  bool _validationSectorError = false;
  bool _validationAdminUserError = false;
  bool _addNewUserError = false;
  String _addNewUserErrorMessage = "";

  Widget _buildAddNewUserError() {
    return Visibility(
        visible: _addNewUserError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0, top: 6.0),
            child: Text(_addNewUserErrorMessage,
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                    fontSize: 16.0))));
  }

  Widget _buildSectorError() {
    return Visibility(
        visible: _validationSectorError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0),
            child: Text("Worker must have sector picked.",
                style: TextStyle(color: Colors.red[600], fontSize: 12.0))));
  }

  Widget _buildAdminUserError() {
    return Visibility(
        visible: _validationAdminUserError,
        child: Container(
            padding: EdgeInsets.only(left: 8.0),
            child: Text("Worker must be admin or user.",
                style: TextStyle(color: Colors.red[600], fontSize: 12.0))));
  }

  Widget _buildWarningForImageAndRights() {
    bool missingImage = false;
    bool missingRights = false;

    String missingImageMessage = "Worker image isn't picked.";
    String missingRightsMessage = "No rights were picked for worker.";

    if (_imageFile == null && !isUserForEdit) {
      missingImage = true;
    }
    if (selectedAdminUser != "Admin") {
      if (selectedRights == null) {
        missingRights = true;
      } else if (selectedRights.isEmpty) {
        missingRights = true;
      } else {
        missingRights = false;
      }
    }

    return isUserForEdit
        ? Text(
            "Are you sure you want to update worker '${widget.userForUpadte.name}' ? ${(missingImage || missingRights) ? " \n\n Warning:" : ""} ${missingImage ? "\n\n- " + missingImageMessage : ""} ${missingRights ? "\n\n- " + missingRightsMessage : ""}")
        : Text(
            "Are you sure you want to add worker '${_nameTextController.text}' ? ${(missingImage || missingRights) ? " \n\n Warning:" : ""} ${missingImage ? "\n\n- " + missingImageMessage : ""} ${missingRights ? "\n\n- " + missingRightsMessage : ""}");
  }
}
