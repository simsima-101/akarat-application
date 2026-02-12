// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Properties';

  @override
  String get search => 'Search';

  @override
  String get properties => 'Properties';

  @override
  String get hello => 'Hello';

  @override
  String get language => 'Language';

  @override
  String get myAccount => 'My Account';

  @override
  String get newProjectsTitle => 'New Projects';

  @override
  String get newProjectsSubtitle =>
      'Find off-plan development and everything you need to know to invest in UAE\'s real estate market';

  @override
  String get latestProjectsTitle => 'Latest Projects in Dubai';

  @override
  String get errorLoadingProjects => 'Failed to load projects.';

  @override
  String get noProjectsFound => 'No properties found.';

  @override
  String get agent => 'Agent';

  @override
  String get priceOnRequest => 'Price on request';

  @override
  String get locationNotAvailable => 'Location not available';

  @override
  String get call => 'Call';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get agentLabel => 'AGENT';

  @override
  String get noTitle => 'No title';

  @override
  String get currencyAed => 'AED';

  @override
  String get projectInformation => 'Project Information';

  @override
  String get projectDetail => 'Project Detail';

  @override
  String get noData => 'No data available';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get loginToAccessFavorites => 'Please login to access your favorites.';

  @override
  String get cancel => 'Cancel';

  @override
  String get login => 'Login';

  @override
  String get welcomeLoginSignUp => 'Welcome! Login / Sign up';

  @override
  String get myProfile => 'My Profile';

  @override
  String get findMyAgent => 'Find My Agent';

  @override
  String get favorites => 'Favorites';

  @override
  String get savedAlerts => 'Saved Alerts';

  @override
  String get contactedProperties => 'Contacted Properties';

  @override
  String get aboutUs => 'About Us';

  @override
  String get support => 'Support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsAndConditions => 'Terms And Conditions';

  @override
  String get rateUs => 'Rate Us';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmationTitle => 'Are you sure you want to logout?';

  @override
  String get loginRequiredTitle => 'Login Required';

  @override
  String get loginToAccessSavedAlerts => 'Please login to access saved alerts.';

  @override
  String get loginToViewContacted =>
      'Please login to view contacted properties.';

  @override
  String get notLoggedInForAction => 'You are not logged in';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String get deletionFailed => 'Deletion failed';

  @override
  String get homeSearchLocationHint => 'Search for a locality, area or city';

  @override
  String get homePropertyForRent => 'Property For Rent';

  @override
  String get homePropertyForSale => 'Property For Sale';

  @override
  String get homeOffPlanProperties => 'Off-Plan Properties';

  @override
  String get homeCommercial => 'Commercial';

  @override
  String get homeVilla => 'Villas';

  @override
  String get homeApartment => 'Apartments';

  @override
  String get homeDiscoverUaeRealEstate =>
      'Discover more about the UAE real estate market';

  @override
  String get homeSortNewest => 'Newest';

  @override
  String get homeSortFeatured => 'Featured';

  @override
  String get homeSortPriceLow => 'Price (Low)';

  @override
  String get homeSortPriceHigh => 'Price (High)';

  @override
  String get loginToEditProfile => 'Please login to edit your profile.';

  @override

  String get myAccountSupportTitle => 'Contact Us';

  @override
  String get myAccountSupportSubTitle => 'Ask us anything?';

  @override
  String get myAccountSupportNameLabel => 'Name';

  @override
  String get myAccountSupportEmailLabel => 'Email Address';

  @override
  String get myAccountSupportPhoneLabel => 'Phone Number';

  @override
  String get myAccountSupportSubjectLabel => 'Subject';

  @override
  String get myAccountSupportMessageLabel => 'Message';

  @override
  String get myAccountSupportSubmitButtonText => 'Submit';

  @override
  String get myAccountSupportValidationEnterText => 'Please enter';

  @override
  String get myAccountSupportValidationEnterPhone =>
      'Please enter Phone Number';

  @override
  String get myAccountSupportValidationPhoneDigitsOnly =>
      'Phone number must contain digits only';

  @override
  String myAccountSupportValidationPhoneLength(Object country, Object length) {
    return 'Phone number must be $length digits for $country';
  }

  @override
  String myAccountSupportValidationRequired(Object label) {
    return 'Please enter $label';
  }

  @override
  String get myAccountSupportValidationEmailRequired => 'Please enter Email';

  @override
  String get myAccountSupportValidationEmailInvalid =>
      'Please enter a valid email';

  String get registerTitle => 'Create Account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get or => 'OR';

  @override
  String get firstNameHint => 'First Name';

  @override
  String get lastNameHint => 'Last Name';

  @override
  String get emailHint => 'E-mail';

  @override
  String get phoneHint => 'Phone';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Confirm Password';

  @override
  String get atLeast8Characters => 'At least 8 characters';

  @override
  String get oneUppercaseLetter => 'One uppercase letter';

  @override
  String get oneNumber => 'One number';

  @override
  String get oneSpecialCharacter => 'One special character';

  @override
  String get registerButton => 'Register';

  @override
  String get bySigningUpAgreeTo => 'By Signing up I agree to the ';

  @override
  String get and => ' and ';

  @override
  String get alreadyHaveAccount => 'Already have an account?  ';

  @override
  String get loginHere => 'Login Here';

  @override
  String get errorFirstNameRequired => 'Please enter first name';

  @override
  String get errorLastNameRequired => 'Please enter last name';

  @override
  String get errorEmailRequired => 'Please enter email';

  @override
  String get errorInvalidEmail => 'Invalid email';

  @override
  String get errorPhoneRequired => 'Please enter phone';

  @override
  String get errorInvalidPhoneDigits => 'Enter a valid number';

  @override
  String errorPhoneLength(Object length, Object countryCode) {
    return 'Phone number must be $length digits for $countryCode';
  }

  @override
  String get errorPasswordRequired => 'Please enter password';

  @override
  String get errorPasswordRequirements => 'Password doesn’t meet requirements';

  @override
  String get errorConfirmPasswordRequired => 'Please confirm password';

  @override
  String get errorPasswordsNotMatch => 'Passwords do not match';

  @override
  String get otpSentMessage => 'OTP sent. Please check your email.';

  @override
  String get registrationTimedOut =>
      'Registration timed out. Please try again.';

  @override
  String get emailAlreadyRegistered =>
      'This email is already registered. Please Login or use Forgot Password.';

  @override
  String get tooManyAttempts =>
      'Too many attempts. Please wait a minute and try again.';

  @override
  String get searchCountryHint => 'Search Country';

  @override
  String get googleSignInNotSupported =>
      'This platform does not support authenticate()';

  @override
  String get firebaseUserNullAfterSignIn =>
      'Sign-in failed. No user account was created.';

  @override
  String get failedToGetFirebaseIdToken =>
      'Failed to retrieve authentication token.';

  @override
  String get accountDeletedOrInactiveContactSupport =>
      'This account has been deleted or is inactive.\nPlease contact support to reactivate it or use a different email';

  @override
  String get accountDeletedOrTokenMissing =>
      'This account has been deleted or token missing.';

  @override
  String get nonJsonFromLoginGoogle =>
      'Invalid response from server. Please try again later.';

  @override
  String googleLoginFailedWithCode(Object code) {
    return 'Google login failed (error $code). Please try again.';
  }

  @override
  String get googleSignInFailedGeneric =>
      'Google Sign-In failed. Please try again.';

}
