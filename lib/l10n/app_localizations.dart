import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get appTitle;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get properties;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Menu item for changing app language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Title for the My Account screen
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get myAccount;

  /// Title of the New Projects screen / app bar
  ///
  /// In en, this message translates to:
  /// **'New Projects'**
  String get newProjectsTitle;

  /// Subtitle text shown on the New Projects screen
  ///
  /// In en, this message translates to:
  /// **'Find off-plan development and everything you need to know to invest in UAE\'s real estate market'**
  String get newProjectsSubtitle;

  /// Message shown when latest project in Dubai
  ///
  /// In en, this message translates to:
  /// **'Latest Projects in Dubai'**
  String get latestProjectsTitle;

  /// Error message when projects fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load projects.'**
  String get errorLoadingProjects;

  /// Message when no projects are available
  ///
  /// In en, this message translates to:
  /// **'No properties found.'**
  String get noProjectsFound;

  /// Fallback text when agent name is missing
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get agent;

  /// Shown when property price is not available
  ///
  /// In en, this message translates to:
  /// **'Price on request'**
  String get priceOnRequest;

  /// Fallback when location is missing
  ///
  /// In en, this message translates to:
  /// **'Location not available'**
  String get locationNotAvailable;

  /// Label on the call button in property card
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Label on the WhatsApp button in property card
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// Small label under agent avatar in property card
  ///
  /// In en, this message translates to:
  /// **'AGENT'**
  String get agentLabel;

  /// Fallback when property title is null
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// Currency suffix for UAE Dirham (keep as code in English)
  ///
  /// In en, this message translates to:
  /// **'AED'**
  String get currencyAed;

  /// Section title for project details
  ///
  /// In en, this message translates to:
  /// **'Project Information'**
  String get projectInformation;

  /// Title for the project detail screen/app bar
  ///
  /// In en, this message translates to:
  /// **'Project Detail'**
  String get projectDetail;

  /// Message shown when project data is missing or null
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Title of the dialog that appears when user tries to access favorites without being logged in
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// Message explaining why login is needed to view favorites
  ///
  /// In en, this message translates to:
  /// **'Please login to access your favorites.'**
  String get loginToAccessFavorites;

  /// Button text to close/cancel the login dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text that takes the user to the login screen
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Shown when user is not logged in on profile card
  ///
  /// In en, this message translates to:
  /// **'Welcome! Login / Sign up'**
  String get welcomeLoginSignUp;

  /// Label for user profile (e.g., in header or menu)
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Menu item to find agent page
  ///
  /// In en, this message translates to:
  /// **'Find My Agent'**
  String get findMyAgent;

  /// Menu item for favorite properties
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Menu item for saved search alerts
  ///
  /// In en, this message translates to:
  /// **'Saved Alerts'**
  String get savedAlerts;

  /// Menu item for properties user has contacted
  ///
  /// In en, this message translates to:
  /// **'Contacted Properties'**
  String get contactedProperties;

  /// Menu item for About Us page
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// Menu item for support/contact page
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Menu item for Privacy Policy page
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Menu item for Terms and Conditions page
  ///
  /// In en, this message translates to:
  /// **'Terms And Conditions'**
  String get termsAndConditions;

  /// Menu item or button to rate the app
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// Menu item or button for logging out
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Title of logout confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmationTitle;

  /// Dialog title when action needs authentication
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequiredTitle;

  /// Message shown when trying to access saved alerts without login
  ///
  /// In en, this message translates to:
  /// **'Please login to access saved alerts.'**
  String get loginToAccessSavedAlerts;

  /// Message shown when trying to view contacted properties without login
  ///
  /// In en, this message translates to:
  /// **'Please login to view contacted properties.'**
  String get loginToViewContacted;

  /// Shown when user tries to delete account or perform authenticated action without being logged in
  ///
  /// In en, this message translates to:
  /// **'You are not logged in'**
  String get notLoggedInForAction;

  /// Shown after successful account deletion
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccessfully;

  /// Prefix for account deletion error messages
  ///
  /// In en, this message translates to:
  /// **'Deletion failed'**
  String get deletionFailed;

  /// Hint text for the search field on the home screen
  ///
  /// In en, this message translates to:
  /// **'Search for a locality, area or city'**
  String get homeSearchLocationHint;

  /// Label for property for rent
  ///
  /// In en, this message translates to:
  /// **'Property For Rent'**
  String get homePropertyForRent;

  /// Label for property for sale
  ///
  /// In en, this message translates to:
  /// **'Property For Sale'**
  String get homePropertyForSale;

  /// Label for off-plan properties
  ///
  /// In en, this message translates to:
  /// **'Off-Plan Properties'**
  String get homeOffPlanProperties;

  /// Label for commercial properties
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get homeCommercial;

  /// Label for villas
  ///
  /// In en, this message translates to:
  /// **'Villas'**
  String get homeVilla;

  /// Label for apartments
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get homeApartment;

  /// Subtitle text shown in the Home screen New Projects section
  ///
  /// In en, this message translates to:
  /// **'Discover more about the UAE real estate market'**
  String get homeDiscoverUaeRealEstate;

  /// Dropdown value shown in the Home screen sorting filter
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get homeSortNewest;

  /// Dropdown value shown in the Home screen sorting filter
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get homeSortFeatured;

  /// Dropdown value shown in the Home screen sorting filter
  ///
  /// In en, this message translates to:
  /// **'Price (Low)'**
  String get homeSortPriceLow;

  /// Dropdown value shown in the Home screen sorting filter
  ///
  /// In en, this message translates to:
  /// **'Price (High)'**
  String get homeSortPriceHigh;

  /// Message shown when user tries to edit profile without being logged in
  ///
  /// In en, this message translates to:
  /// **'Please login to edit your profile.'**
  String get loginToEditProfile;

  /// This text is displayed in the support screen app bar title of the My Account screen
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get myAccountSupportTitle;

  /// this is the sub title show in teh support screen in the my screen.
  ///
  /// In en, this message translates to:
  /// **'Ask us anything?'**
  String get myAccountSupportSubTitle;

  /// Label text for the name input field on the support screen in the My Account screen
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get myAccountSupportNameLabel;

  /// Label text for the email input field on the support screen in the My Account screen
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get myAccountSupportEmailLabel;

  /// Label text for the phone number input field on the support screen in the My Account screen
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get myAccountSupportPhoneLabel;

  /// Label text for the subject input field on the support screen in the My Account screen
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get myAccountSupportSubjectLabel;

  /// Label text for the message input field on the support screen in the My Account screen
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get myAccountSupportMessageLabel;

  /// Text for the submit button on the support form in the My Account screen
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get myAccountSupportSubmitButtonText;

  /// Validation message shown on the My Account support screen when a required text field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get myAccountSupportValidationEnterText;

  /// Validation message shown on the My Account support screen when the phone number field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter Phone Number'**
  String get myAccountSupportValidationEnterPhone;

  /// Validation message shown on the My Account support screen when the phone number contains non-numeric characters
  ///
  /// In en, this message translates to:
  /// **'Phone number must contain digits only'**
  String get myAccountSupportValidationPhoneDigitsOnly;

  /// Validation message shown on the My Account support screen when the phone number length is invalid for the selected country; {length} and {country} are dynamic values
  ///
  /// In en, this message translates to:
  /// **'Phone number must be {length} digits for {country}'**
  String myAccountSupportValidationPhoneLength(Object country, Object length);

  /// Validation error on the My Account > Support screen when a required text field is empty. {label} is the field name.
  ///
  /// In en, this message translates to:
  /// **'Please enter {label}'**
  String myAccountSupportValidationRequired(Object label);

  /// Validation error on the My Account > Support screen when the Email text field is empty.
  ///
  /// In en, this message translates to:
  /// **'Please enter Email'**
  String get myAccountSupportValidationEmailRequired;

  /// Validation error on the My Account > Support screen when the Email text field has an invalid format.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get myAccountSupportValidationEmailInvalid;

  /// Title of the registration screen app bar
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// Label on Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Separator between sign-in methods
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Hint for first name field
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameHint;

  /// Hint for last name field
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameHint;

  /// Hint for email field
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get emailHint;

  /// Hint for phone number field
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneHint;

  /// Hint for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// Hint for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordHint;

  /// Password rule - length
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// Password rule - uppercase
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get oneUppercaseLetter;

  /// Password rule - digit
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get oneNumber;

  /// Password rule - special char
  ///
  /// In en, this message translates to:
  /// **'One special character'**
  String get oneSpecialCharacter;

  /// Label on register submit button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// Start of terms/privacy agreement sentence
  ///
  /// In en, this message translates to:
  /// **'By Signing up I agree to the '**
  String get bySigningUpAgreeTo;

  /// Conjunction in terms/privacy sentence
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// Text before login link
  ///
  /// In en, this message translates to:
  /// **'Already have an account?  '**
  String get alreadyHaveAccount;

  /// Login link text
  ///
  /// In en, this message translates to:
  /// **'Login Here'**
  String get loginHere;

  /// Validation error - missing first name
  ///
  /// In en, this message translates to:
  /// **'Please enter first name'**
  String get errorFirstNameRequired;

  /// Validation error - missing last name
  ///
  /// In en, this message translates to:
  /// **'Please enter last name'**
  String get errorLastNameRequired;

  /// Validation error - missing email
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get errorEmailRequired;

  /// Validation error - bad email format
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get errorInvalidEmail;

  /// Validation error - missing phone
  ///
  /// In en, this message translates to:
  /// **'Please enter phone'**
  String get errorPhoneRequired;

  /// Validation error - invalid phone characters
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get errorInvalidPhoneDigits;

  /// Validation error - wrong phone length
  ///
  /// In en, this message translates to:
  /// **'Phone number must be {length} digits for {countryCode}'**
  String errorPhoneLength(Object length, Object countryCode);

  /// Validation error - missing password
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get errorPasswordRequired;

  /// Validation error - password too weak
  ///
  /// In en, this message translates to:
  /// **'Password doesn’t meet requirements'**
  String get errorPasswordRequirements;

  /// Validation error - missing confirmation
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get errorConfirmPasswordRequired;

  /// Validation error - passwords mismatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordsNotMatch;

  /// Success message after registration
  ///
  /// In en, this message translates to:
  /// **'OTP sent. Please check your email.'**
  String get otpSentMessage;

  /// Timeout error message
  ///
  /// In en, this message translates to:
  /// **'Registration timed out. Please try again.'**
  String get registrationTimedOut;

  /// Error when email is taken
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please Login or use Forgot Password.'**
  String get emailAlreadyRegistered;

  /// Rate limit error message
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a minute and try again.'**
  String get tooManyAttempts;

  /// Search for Country
  ///
  /// In en, this message translates to:
  /// **'Search Country'**
  String get searchCountryHint;

  /// This platform does not support authenticate()
  ///
  /// In en, this message translates to:
  /// **'This platform does not support authenticate()'**
  String get googleSignInNotSupported;

  /// Error when Firebase returns no user after Google credential sign-in
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. No user account was created.'**
  String get firebaseUserNullAfterSignIn;

  /// Error when Firebase ID token cannot be obtained
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve authentication token.'**
  String get failedToGetFirebaseIdToken;

  /// User-facing error when account is deleted/inactive after Google sign-in
  ///
  /// In en, this message translates to:
  /// **'This account has been deleted or is inactive.\nPlease contact support to reactivate it or use a different email'**
  String get accountDeletedOrInactiveContactSupport;

  /// Technical error when backend token is null/empty or account is deleted
  ///
  /// In en, this message translates to:
  /// **'This account has been deleted or token missing.'**
  String get accountDeletedOrTokenMissing;

  /// User-friendly message when /login-google returns HTML instead of JSON
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server. Please try again later.'**
  String get nonJsonFromLoginGoogle;

  /// Generic Google login failure with status code
  ///
  /// In en, this message translates to:
  /// **'Google login failed (error {code}). Please try again.'**
  String googleLoginFailedWithCode(Object code);

  /// Fallback generic error for any Google Sign-In issue
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed. Please try again.'**
  String get googleSignInFailedGeneric;

  /// App bar title text shown on the Terms & Conditions screen in the My Account section
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get myAccountTermsAndConditionsAppBarTitle;

  /// Section title for the introduction
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get myAccountTermsSectionIntroductionTitle;

  /// Full introduction text in Terms & Conditions
  ///
  /// In en, this message translates to:
  /// **'Welcome to Akarat (the “Platform”). These Terms & Conditions (“Terms”) serve as a legally binding agreement between Akarat and any individual or entity who accesses, uses, or interacts with our website, mobile application, digital solutions, or any related tools and functionalities (collectively, the “Services”). These Terms apply to all categories of users, including visitors, registered members, advertisers, licensed agents, developers, and any other parties accessing or utilizing the Platform.\n\nBy using or accessing any component of the Platform, you acknowledge that you have read, understood, and agreed to comply with these Terms, together with our Privacy Policy. If you disagree with any provision contained herein, you must immediately discontinue use of the Platform and all associated Services.'**
  String get myAccountTermsSectionIntroductionContent;

  /// Title of the 'Who We Are' section including numbering
  ///
  /// In en, this message translates to:
  /// **'1. Who We Are'**
  String get myAccountTermsSectionWhoWeAreTitle;

  /// Company name and country of registration
  ///
  /// In en, this message translates to:
  /// **'The Platform is owned and operated by EMLAK BULUCU PORTAL LLC, a legally registered entity in the United Arab Emirates (UAE).'**
  String get myAccountTermsWhoWeAreCompany;

  /// Registered office address and email
  ///
  /// In en, this message translates to:
  /// **'Registered Office: Westburry Office Tower, Floor 23, Office No. 2303, Business Bay, Dubai, UAE\nEmail: info@akarat.com'**
  String get myAccountTermsWhoWeAreOffice;

  /// Explanation of who 'we' refers to
  ///
  /// In en, this message translates to:
  /// **'References to “we,” “us,” or “our” refer to Akarat as the Platform operator.'**
  String get myAccountTermsWhoWeArePronouns;

  /// Title of the Definitions section including numbering
  ///
  /// In en, this message translates to:
  /// **'2. Definitions'**
  String get myAccountTermsSectionDefinitionsTitle;

  /// Definition of Advertiser
  ///
  /// In en, this message translates to:
  /// **'Advertiser: Any individual, business, or organization that posts property listings on the Platform to promote, market, or sell properties.'**
  String get myAccountTermsDefinitionAdvertiser;

  /// Definition of Agent
  ///
  /// In en, this message translates to:
  /// **'Agent: A licensed real estate professional, broker, or agency authorized to list or market properties.'**
  String get myAccountTermsDefinitionAgent;

  /// Definition of Content
  ///
  /// In en, this message translates to:
  /// **'Content: All materials uploaded or submitted to the Platform, including text, images, videos, documents, graphics, and other media.'**
  String get myAccountTermsDefinitionContent;

  /// Definition of Listing
  ///
  /// In en, this message translates to:
  /// **'Listing: Any property advertisement, promotional entry, or post published on the Platform, including all related details and media.'**
  String get myAccountTermsDefinitionListing;

  /// Definition of User / You
  ///
  /// In en, this message translates to:
  /// **'User / You: Any person, company, or entity who accesses, navigates, or interacts with the Platform or its Services.'**
  String get myAccountTermsDefinitionUser;

  /// Definition of Services
  ///
  /// In en, this message translates to:
  /// **'Services: The complete range of features, tools, functionalities, and solutions offered by Akarat through the Platform.'**
  String get myAccountTermsDefinitionServices;

  /// Title of Acceptance of Terms section
  ///
  /// In en, this message translates to:
  /// **'3. Acceptance of Terms'**
  String get myAccountTermsSectionAcceptanceTitle;

  /// Main acceptance paragraph
  ///
  /// In en, this message translates to:
  /// **'By accessing or using the Platform, you expressly acknowledge that you have read, understood, and agreed to be bound by these Terms. Your use of the Platform signifies your acceptance of all obligations outlined herein.'**
  String get myAccountTermsAcceptanceMain;

  /// Intro to list of prohibited users
  ///
  /// In en, this message translates to:
  /// **'You may not use the Platform if any of the following apply:'**
  String get myAccountTermsAcceptanceNotAllowed;

  /// List of cases when platform cannot be used
  ///
  /// In en, this message translates to:
  /// **'• You are under the age of 18 years.\n• Your jurisdiction prohibits access to digital property marketplaces.\n• You do not meet the eligibility or legal requirements to list, advertise, or interact with property listings.'**
  String get myAccountTermsAcceptanceConditions;

  /// Text about terms updates
  ///
  /// In en, this message translates to:
  /// **'Akarat reserves the right to modify, amend, or update these Terms at any time without prior notice. Updates become effective immediately upon publication. Continued use of the Platform after such changes constitutes acceptance of the revised Terms.'**
  String get myAccountTermsAcceptanceUpdates;

  /// Title of Scope of Use section
  ///
  /// In en, this message translates to:
  /// **'4. Scope of Use'**
  String get myAccountTermsSectionScopeTitle;

  /// Introduction to prohibited actions
  ///
  /// In en, this message translates to:
  /// **'Users must utilize the Platform professionally, ethically, and in accordance with all applicable laws. You are strictly prohibited from:'**
  String get myAccountTermsScopeIntro;

  /// List of prohibited activities
  ///
  /// In en, this message translates to:
  /// **'• Uploading unlawful, misleading, fraudulent, or copyrighted material without permission.\n• Scraping, mining, copying, or extracting Platform data for commercial use.\n• Posting inaccurate, duplicate, or non-existent property listings.\n• Using automated tools, bots, or scripts to access or interact with the Platform.\n• Attempting to harm, disable, overburden, or interfere with Platform security or operations.'**
  String get myAccountTermsScopeProhibited;

  /// Consequence of misuse
  ///
  /// In en, this message translates to:
  /// **'Misuse may result in immediate suspension, account termination, content removal, or legal action.'**
  String get myAccountTermsScopeConsequence;

  /// Title of Account Registration section
  ///
  /// In en, this message translates to:
  /// **'5. Account Registration'**
  String get myAccountTermsSectionRegistrationTitle;

  /// Introduction to account responsibilities
  ///
  /// In en, this message translates to:
  /// **'Certain Services require user registration. You must provide accurate, complete, and up-to-date information. Users are responsible for:'**
  String get myAccountTermsRegistrationIntro;

  /// List of user responsibilities
  ///
  /// In en, this message translates to:
  /// **'• Protecting login credentials\n• Preventing unauthorized access\n• All activity performed under their account'**
  String get myAccountTermsRegistrationDuties;

  /// Disclaimer about account security
  ///
  /// In en, this message translates to:
  /// **'Akarat is not liable for losses resulting from negligence or unauthorized access.'**
  String get myAccountTermsRegistrationNoLiability;

  /// Title of Advertiser & Agent Obligations section
  ///
  /// In en, this message translates to:
  /// **'6. Advertiser & Agent Obligations'**
  String get myAccountTermsSectionAdvertiserAgentTitle;

  /// Compliance requirement for advertisers and agents
  ///
  /// In en, this message translates to:
  /// **'Advertisers and Agents must comply with all relevant UAE real estate regulations, including licensing and advertising requirements set by authorities such as the DLD (Dubai Land Department).'**
  String get myAccountTermsAdvertiserAgentCompliance;

  /// Introduction to listing requirements
  ///
  /// In en, this message translates to:
  /// **'All property listings must:'**
  String get myAccountTermsListingMust;

  /// Requirements for property listings
  ///
  /// In en, this message translates to:
  /// **'• Be accurate, truthful, and currently available.\n• Contain updated information, images, specifications, and pricing.\n• Be backed by valid authorization, ownership documents, or listing agreements.'**
  String get myAccountTermsListingRequirements;

  /// Introduction to Akarat's rights over listings
  ///
  /// In en, this message translates to:
  /// **'Akarat reserves full rights to:'**
  String get myAccountTermsAkaratRights;

  /// List of Akarat's rights regarding listings
  ///
  /// In en, this message translates to:
  /// **'• Review and approve listings before publication.\n• Edit or remove content that violates guidelines.\n• Suspend accounts engaged in dishonest or unethical practices.'**
  String get myAccountTermsAkaratRightsList;

  /// License requirement for agents
  ///
  /// In en, this message translates to:
  /// **'Agents must hold a valid DLD license or equivalent certification depending on the emirate.'**
  String get myAccountTermsAgentLicense;

  /// Title of User-Generated Content section
  ///
  /// In en, this message translates to:
  /// **'7. User-Generated Content'**
  String get myAccountTermsSectionUGCTitle;

  /// License granted for uploaded content
  ///
  /// In en, this message translates to:
  /// **'By uploading content, you grant Akarat a global, non-exclusive, royalty-free license to store, publish, reproduce, modify, or use the content for Platform-related purposes.'**
  String get myAccountTermsUGCLicense;

  /// Introduction to content ownership affirmation
  ///
  /// In en, this message translates to:
  /// **'You affirm that:'**
  String get myAccountTermsUGCAffirm;

  /// Affirmations about content ownership
  ///
  /// In en, this message translates to:
  /// **'• You own the content or possess legal usage rights.\n• Your content does not violate intellectual property laws.'**
  String get myAccountTermsUGCAffirmList;

  /// Title of Intellectual Property section
  ///
  /// In en, this message translates to:
  /// **'8. Intellectual Property'**
  String get myAccountTermsSectionIPTitle;

  /// Statement of IP ownership
  ///
  /// In en, this message translates to:
  /// **'All intellectual property rights in the Platform, including but not limited to trademarks, service marks, logos, graphics, text, images, audiovisual material, software, design elements, and other content, are the exclusive property of Akarat or its licensors.'**
  String get myAccountTermsIPOwnership;

  /// Introduction to prohibited IP actions
  ///
  /// In en, this message translates to:
  /// **'Users are strictly prohibited from:'**
  String get myAccountTermsIPProhibited;

  /// Prohibited uses of intellectual property
  ///
  /// In en, this message translates to:
  /// **'• Copying, reproducing, or distributing any Platform content without prior written consent.\n• Modifying, creating derivative works, or commercially exploiting the Platform or its content.\n• Using intellectual property in any way that infringes on the rights of Akarat or third-party licensors.'**
  String get myAccountTermsIPProhibitedList;

  /// Consequence of IP infringement
  ///
  /// In en, this message translates to:
  /// **'Any unauthorized use of the Platform’s intellectual property may result in civil or criminal liability under the applicable laws of the United Arab Emirates.'**
  String get myAccountTermsIPConsequence;

  /// Title of Disclaimer and Limitation of Liability section
  ///
  /// In en, this message translates to:
  /// **'9. Disclaimer & Limitation of Liability'**
  String get myAccountTermsSectionDisclaimerTitle;

  /// As-is disclaimer
  ///
  /// In en, this message translates to:
  /// **'The Platform and its Services are provided on an “as-is” and “as-available” basis. Akarat makes no warranties, whether express or implied, regarding the availability, accuracy, completeness, reliability, or fitness for purpose of any content, listings, or Services offered through the Platform.'**
  String get myAccountTermsDisclaimerBasis;

  /// Introduction to what Akarat is not liable for
  ///
  /// In en, this message translates to:
  /// **'Users acknowledge and agree that Akarat is not liable for:'**
  String get myAccountTermsNoLiabilityFor;

  /// List of non-liabilities
  ///
  /// In en, this message translates to:
  /// **'• Errors, omissions, or outdated information in property listings or user-generated content.\n• Indirect, incidental, consequential, punitive, or special damages, including lost profits, lost opportunities, or business interruptions.\n• Misconduct, misrepresentation, negligence, or any actions taken by advertisers, agents, users, or third-party entities.'**
  String get myAccountTermsNoLiabilityList;

  /// Own risk clause and liability cap
  ///
  /// In en, this message translates to:
  /// **'Users access and use the Platform entirely at their own risk. The total aggregate liability of Akarat, whether in contract, tort, or otherwise, shall not exceed the fees, if any, paid by the user for the relevant Services.'**
  String get myAccountTermsUseAtOwnRisk;

  /// Title of Suspension or Termination section
  ///
  /// In en, this message translates to:
  /// **'10. Suspension or Termination'**
  String get myAccountTermsSectionSuspensionTitle;

  /// Introduction to suspension/termination rights
  ///
  /// In en, this message translates to:
  /// **'Akarat reserves the right, at its sole discretion, to suspend, restrict, or terminate a user’s account and access to the Platform, in whole or in part, without prior notice, if:'**
  String get myAccountTermsSuspensionRight;

  /// Reasons for suspension or termination
  ///
  /// In en, this message translates to:
  /// **'• The user violates any provision of these Terms or applicable law.\n• Fraudulent, abusive, or unethical activity is detected.\n• Security of the Platform or other users is threatened.'**
  String get myAccountTermsSuspensionReasons;

  /// Effects of suspension or termination
  ///
  /// In en, this message translates to:
  /// **'Upon suspension or termination, access to all Services, content, and user data will be immediately revoked. Users remain liable for all obligations and actions performed under their account prior to termination.'**
  String get myAccountTermsSuspensionEffect;

  /// Title of Data Protection & Privacy section
  ///
  /// In en, this message translates to:
  /// **'11. Data Protection & Privacy'**
  String get myAccountTermsSectionPrivacyTitle;

  /// Introduction to data processing
  ///
  /// In en, this message translates to:
  /// **'All personal and non-personal data collected through the Platform are processed in accordance with Akarat’s Privacy Policy. Key practices include:'**
  String get myAccountTermsPrivacyProcessed;

  /// Key data protection practices
  ///
  /// In en, this message translates to:
  /// **'• Collection of data only for operational, legal, or service-related purposes.\n• Secure storage of data and restriction of access to authorized personnel only.\n• Use of personal data solely for improving Services, processing transactions, or complying with legal obligations.\n• User rights to access, correct, or request deletion of personal information, subject to applicable UAE laws.'**
  String get myAccountTermsPrivacyPractices;

  /// Consent to privacy policy
  ///
  /// In en, this message translates to:
  /// **'By using the Platform, users consent to the collection, processing, and storage of data as described in the Privacy Policy.'**
  String get myAccountTermsPrivacyConsent;

  /// Title of Third-Party Links section
  ///
  /// In en, this message translates to:
  /// **'12. Third-Party Links'**
  String get myAccountTermsSectionThirdPartyTitle;

  /// Full text about third-party links and disclaimer
  ///
  /// In en, this message translates to:
  /// **'The Platform may contain links to third-party websites, applications, or services. Akarat does not control, endorse, or guarantee the accuracy, content, privacy, or security of third-party sites.\n\nUsers acknowledge that access to external websites or resources is at their own risk. Akarat disclaims all liability for any damages or losses incurred as a result of using such third-party services.'**
  String get myAccountTermsThirdPartyContent;

  /// Title of Governing Law & Jurisdiction section
  ///
  /// In en, this message translates to:
  /// **'13. Governing Law & Jurisdiction'**
  String get myAccountTermsSectionGoverningLawTitle;

  /// Governing law and jurisdiction clause
  ///
  /// In en, this message translates to:
  /// **'These Terms shall be governed by and construed in accordance with the laws of the United Arab Emirates. Any dispute, controversy, or claim arising out of or in connection with these Terms, or the use of the Platform, shall be subject to the exclusive jurisdiction of the competent courts in Dubai.\n\nUsers expressly submit to the jurisdiction of such courts and waive any objection to venue or inconvenient forum.'**
  String get myAccountTermsGoverningLawContent;

  /// Title of Language section
  ///
  /// In en, this message translates to:
  /// **'14. Language'**
  String get myAccountTermsSectionLanguageTitle;

  /// Language precedence clause
  ///
  /// In en, this message translates to:
  /// **'These Terms are provided in both English and Arabic for convenience. In the event of any conflict or inconsistency between the English and Arabic versions, the English version shall prevail for all legal purposes, interpretation, and enforcement.'**
  String get myAccountTermsLanguageContent;

  /// Title of Updates to These Terms section
  ///
  /// In en, this message translates to:
  /// **'15. Updates to These Terms'**
  String get myAccountTermsSectionUpdatesTitle;

  /// Introduction to updates
  ///
  /// In en, this message translates to:
  /// **'Akarat reserves the right to amend, revise, or update these Terms at any time to reflect changes in:'**
  String get myAccountTermsUpdatesIntro;

  /// Reasons for updating terms
  ///
  /// In en, this message translates to:
  /// **'• Legal or regulatory requirements.\n• Operational, technical, or security improvements.\n• New features, functionalities, or Services offered through the Platform.'**
  String get myAccountTermsUpdatesReasons;

  /// Effect and acceptance of updated terms
  ///
  /// In en, this message translates to:
  /// **'Updated Terms become effective immediately upon publication on the Platform. Users are encouraged to periodically review the Terms. Continued use of the Platform constitutes acceptance of any modifications or updates.'**
  String get myAccountTermsUpdatesEffect;

  /// Title of Contact Us section
  ///
  /// In en, this message translates to:
  /// **'16. Contact Us'**
  String get myAccountTermsSectionContactTitle;

  /// Contact information text
  ///
  /// In en, this message translates to:
  /// **'For assistance, inquiries, or complaints:\n\n✉️ info@akarat.com\n\n📍 Westburry Office Tower, Floor 23, Office 2303, Business Bay, Dubai, UAE'**
  String get myAccountTermsContactContent;

  /// App bar title for the Privacy Policy screen in My Account section
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get myAccountPrivacyAppBarTitle;

  /// Section title: Introduction
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get myAccountPrivacyIntroductionTitle;

  /// Main introduction paragraph of the Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'Protecting your privacy is a priority for Akarat. We are committed to safeguarding your Personal Data and being transparent about how it is collected, used, and disclosed in connection with your use of our website and mobile applications (the “Platform”).\n\nThis Privacy Policy explains how Akarat collects, processes, and manages your Personal Data when you access or use the Platform, and outlines your rights and the legal protections available to you.\n\nBy accessing or using the Platform, you acknowledge and agree to the collection, use, and transfer of your Personal Data in accordance with this Privacy Policy.'**
  String get myAccountPrivacyIntroductionContent;

  /// Intro text before the list of sections
  ///
  /// In en, this message translates to:
  /// **'This Privacy Policy covers the following sections:'**
  String get myAccountPrivacySectionsIntro;

  /// Clickable link title to 'Who We Are & Contact' section
  ///
  /// In en, this message translates to:
  /// **'About our company and contact information'**
  String get myAccountPrivacySectionLinkAbout;

  /// Clickable link title to Types of Information section
  ///
  /// In en, this message translates to:
  /// **'Types of information we collect'**
  String get myAccountPrivacySectionLinkTypes;

  /// Clickable link title to Legal Basis section
  ///
  /// In en, this message translates to:
  /// **'Legal Basis for Processing Your Information'**
  String get myAccountPrivacySectionLinkLegal;

  /// Clickable link title to Sharing section
  ///
  /// In en, this message translates to:
  /// **'How We Share Your Information'**
  String get myAccountPrivacySectionLinkShare;

  /// Clickable link title to Security section
  ///
  /// In en, this message translates to:
  /// **'Data Security Measures'**
  String get myAccountPrivacySectionLinkSecurity;

  /// Clickable link title to Rights section
  ///
  /// In en, this message translates to:
  /// **'Your Rights Regarding Your Information'**
  String get myAccountPrivacySectionLinkRights;

  /// Clickable link title to Marketing section
  ///
  /// In en, this message translates to:
  /// **'Marketing and Promotional Communications'**
  String get myAccountPrivacySectionLinkMarketing;

  /// Clickable link title to Minors section
  ///
  /// In en, this message translates to:
  /// **'Information About Minors'**
  String get myAccountPrivacySectionLinkMinors;

  /// Clickable link title to Third-Party Links section
  ///
  /// In en, this message translates to:
  /// **'Links to Third-Party'**
  String get myAccountPrivacySectionLinkThirdParty;

  /// Clickable link title to Updates section
  ///
  /// In en, this message translates to:
  /// **'Policy Updates and Revisions'**
  String get myAccountPrivacySectionLinkUpdates;

  /// Footer note about updates and language precedence
  ///
  /// In en, this message translates to:
  /// **'We may revise this Privacy Policy periodically. The latest version will always be available on this page.\n\nIf this Policy is published in different languages and any discrepancies arise, the English version shall prevail.'**
  String get myAccountPrivacyFooterNote;

  /// Main heading for company & contact section
  ///
  /// In en, this message translates to:
  /// **'Who We Are & How to Contact Us?'**
  String get myAccountPrivacySectionWhoWeAreTitle;

  /// Subheading: Who are we?
  ///
  /// In en, this message translates to:
  /// **'Who are we?'**
  String get myAccountPrivacyWhoWeAreSubtitle;

  /// Company description and registration info
  ///
  /// In en, this message translates to:
  /// **'The Platform is operated by EMLAK BULUCU, a company registered in the United Arab Emirates, with its registered address at Westburry Office Tower, Floor 23, Office No. 2303, Business Bay, Dubai, UAE (“Akarat”, “we”, “us”, “our”).'**
  String get myAccountPrivacyWhoWeAreContent;

  /// Subheading: How to contact us?
  ///
  /// In en, this message translates to:
  /// **'How to contact us?'**
  String get myAccountPrivacyContactSubtitle;

  /// Contact instruction text
  ///
  /// In en, this message translates to:
  /// **'You may contact us via email at info@akarat.com for any inquiries related to this Privacy Policy.'**
  String get myAccountPrivacyContactContent;

  /// Main heading for data collection section
  ///
  /// In en, this message translates to:
  /// **'Informations We Collect & How We Use It'**
  String get myAccountPrivacySectionTypesTitle;

  /// Intro sentence before personal data explanation
  ///
  /// In en, this message translates to:
  /// **'The categories of Personal Data we collect directly from you are outlined below.'**
  String get myAccountPrivacyTypesIntro;

  /// Definition of Personal Data and exclusion of listing details
  ///
  /// In en, this message translates to:
  /// **'“Personal Data” refers to any information that identifies you or can reasonably be used to identify you. This does not include anonymised or aggregated data that cannot be linked back to you. Property listing details—such as photos, prices, descriptions, and amenities—are not considered Personal Data, as they relate to properties and do not identify individuals.'**
  String get myAccountPrivacyPersonalDataDefinition;

  /// Intro before the list of data categories
  ///
  /// In en, this message translates to:
  /// **'The types of Personal Data we may collect include:'**
  String get myAccountPrivacyTypesCollectedIntro;

  /// Bullet list of main data categories
  ///
  /// In en, this message translates to:
  /// **'→ User Information\n→ Agency Information\n→ Agent Information\n→ Property Creation Information\n→ Chat Data\n→ Technical Data\n→ Marketing Data'**
  String get myAccountPrivacyTypesList;

  /// Subsection title: User Information
  ///
  /// In en, this message translates to:
  /// **'→ User Information (for Registration and Login)'**
  String get myAccountPrivacyUserInfoTitle;

  /// Purpose of collecting user registration data
  ///
  /// In en, this message translates to:
  /// **'When you register on Akarat.com, we collect certain personal information to create and manage your account, verify your identity, and personalize your experience on the Platform.'**
  String get myAccountPrivacyUserInfoPurpose;

  /// Subheading for list of user details
  ///
  /// In en, this message translates to:
  /// **'Account and Identity Details We Collect:'**
  String get myAccountPrivacyUserInfoCollectedTitle;

  /// List of user registration fields collected
  ///
  /// In en, this message translates to:
  /// **'• Full Name (First and Last Name)\n• Email Address\n• Mobile Number (including country code)\n• WhatsApp Number\n• Password and login credentials\n• Google Sign-In details (if you choose “Continue with Google”)\n• Verification codes or OTPs used for account setup, login, or security checks'**
  String get myAccountPrivacyUserInfoCollectedList;

  /// Subsection title: Agency Information
  ///
  /// In en, this message translates to:
  /// **'→ Agency Information'**
  String get myAccountPrivacyAgencyInfoTitle;

  /// List of agency registration fields
  ///
  /// In en, this message translates to:
  /// **'• Agency Name and Emirate\n• National ID and property location\n• Registered license number of Agency\n• Registered logo of Agency\n• Registered company license document\n• Registered office registration number'**
  String get myAccountPrivacyAgencyInfoList;

  /// Purpose of collecting agency data
  ///
  /// In en, this message translates to:
  /// **'We collect Agency data to verify the legitimacy of the business and ensure compliance with licensing requirements. This information allows us to create and display a verified Agency profile on Akarat.com, facilitate transparent communication between users and registered Agencies, and efficiently manage property listings and the agents associated with each Agency.'**
  String get myAccountPrivacyAgencyPurpose;

  /// Subheading for public display items
  ///
  /// In en, this message translates to:
  /// **'Akarat may publicly display:'**
  String get myAccountPrivacyAgencyPublicDisplayTitle;

  /// What is shown publicly for agencies
  ///
  /// In en, this message translates to:
  /// **'• Agency name, logo, ORN, and contact information\n• Office address and linked Agents\n• Publicly listed properties (views, listings)\n\nSensitive registration or licensing documents remain strictly confidential.'**
  String get myAccountPrivacyAgencyPublicDisplayList;

  /// Subsection title: Agent Information
  ///
  /// In en, this message translates to:
  /// **'→ Agent Information'**
  String get myAccountPrivacyAgentInfoTitle;

  /// List of agent registration fields
  ///
  /// In en, this message translates to:
  /// **'• Agent name and Emirate\n• Registered Agent License Number\n• Agent National ID\n• Agent profile photo\n• Mobile phone number and WhatsApp number\n• Nationality'**
  String get myAccountPrivacyAgentInfoList;

  /// Purpose and public display rules for agents
  ///
  /// In en, this message translates to:
  /// **'We collect Agent data to verify their professional identity and authorization under RERA/DLD guidelines, to display verified Agent profiles on Akarat.com, and to facilitate communication between Agents and potential clients. Only limited information is displayed publicly, such as the Agent’s name, profile photo, linked Agency name and logo, and active property listings.\n\nSensitive documents, including copies of Emirates IDs, are never shared publicly.'**
  String get myAccountPrivacyAgentPurpose;

  /// Subsection title: Property Creation Information
  ///
  /// In en, this message translates to:
  /// **'→ Property Creation Information'**
  String get myAccountPrivacyPropertyInfoTitle;

  /// Intro to property listing data collection
  ///
  /// In en, this message translates to:
  /// **'When you list or manage a property on Akarat.com, we collect specific details to ensure your listing is complete, accurate, and compliant.'**
  String get myAccountPrivacyPropertyPurpose;

  /// Subheading for property data list
  ///
  /// In en, this message translates to:
  /// **'Information Collected:'**
  String get myAccountPrivacyPropertyCollectedTitle;

  /// List of property listing fields collected
  ///
  /// In en, this message translates to:
  /// **'• Emirate and Trakheesi license details\n• Property Title and Description\n• Property type (e.g., apartment, villa, office, land)\n• Location and map coordinates\n• Payment details and rental period\n• Area size, number of bedrooms and bathrooms\n• Amenities and furnishing details\n• Availability status of property\n• All project-related details\n• Uploaded media (Photos, Floor Plans, YouTube Link)'**
  String get myAccountPrivacyPropertyCollectedList;

  /// Explanation of Trakheesi and purpose of property data
  ///
  /// In en, this message translates to:
  /// **'A Trakheesi license is a mandatory permit issued by the Dubai Land Department (DLD) through RERA, regulating all real estate advertising in Dubai. It ensures that property advertisements are legitimate, traceable, and compliant.\n\nWe collect property listing information to publish and display your listings to potential buyers or tenants, verify authenticity, improve search accuracy, and ensure advertising compliance in the UAE.'**
  String get myAccountPrivacyTrakheesiNote;

  /// Subsection title: Chat Data
  ///
  /// In en, this message translates to:
  /// **'→ Chat Data'**
  String get myAccountPrivacyChatDataTitle;

  /// Explanation and usage of chat data
  ///
  /// In en, this message translates to:
  /// **'Chat Data refers to the messages you exchange through the Platform. This includes any text sent or received. We use this data to facilitate communication between users and Agents, respond to inquiries, provide support, maintain a record of interactions, and improve our services.\n\nChat Data is confidential and securely stored in accordance with this Privacy Policy.'**
  String get myAccountPrivacyChatDataContent;

  /// Subsection title: Technical Data
  ///
  /// In en, this message translates to:
  /// **'→ Technical Data'**
  String get myAccountPrivacyTechnicalDataTitle;

  /// List of technical / device data points
  ///
  /// In en, this message translates to:
  /// **'• IP Address\n• Login Data\n• Browser type and version\n• Operating system and platform\n• Device information\n• Time zone settings'**
  String get myAccountPrivacyTechnicalDataList;

  /// Purpose of collecting technical data
  ///
  /// In en, this message translates to:
  /// **'We collect technical data to understand how users interact with our Platform, diagnose issues, improve performance and functionality, enhance security, and optimize user experience. This data may also be used for analytics, fraud detection, and regulatory compliance.'**
  String get myAccountPrivacyTechnicalPurpose;

  /// Subsection title: Marketing Data
  ///
  /// In en, this message translates to:
  /// **'→ Marketing Data'**
  String get myAccountPrivacyMarketingDataTitle;

  /// Full text about marketing preferences and opt-out
  ///
  /// In en, this message translates to:
  /// **'We may collect and store your preferences regarding the marketing communications you wish to receive from us, including property alerts, account updates, enquiry responses, and promotional messages. This helps us tailor communication to your interests.\n\nYou may opt out at any time by clicking the “Unsubscribe” link in any marketing email or by contacting us at info@akarat.com. Opting out will not affect your ability to use the Platform.'**
  String get myAccountPrivacyMarketingContent;

  /// Heading: What if user refuses to provide data
  ///
  /// In en, this message translates to:
  /// **'What happens if you refuse to provide necessary Personal Data?'**
  String get myAccountPrivacyRefusalTitle;

  /// Consequence of not providing required data
  ///
  /// In en, this message translates to:
  /// **'You are not required to provide Personal Data to us. However, if certain data is necessary to access the Platform or comply with legal requirements, and you do not provide it, we may be unable to grant access. For example, we require your email address to register your account on Akarat.com.'**
  String get myAccountPrivacyRefusalContent;

  /// Main heading: Legal Basis for Processing
  ///
  /// In en, this message translates to:
  /// **'Legal Basis for Processing'**
  String get myAccountPrivacySectionLegalTitle;

  /// Introduction to legal bases
  ///
  /// In en, this message translates to:
  /// **'Under applicable privacy laws, we must ensure that each purpose for which we use your Personal Data is supported by a valid legal basis. In most cases, we rely on one of the following:'**
  String get myAccountPrivacyLegalIntro;

  /// List of legal bases for processing
  ///
  /// In en, this message translates to:
  /// **'• Contractual Necessity – When processing your Personal Data is required to fulfil our contract with you (for example, enabling your access to the Platform).\n\n• Compliance with Law – When we must process your Personal Data to meet legal or regulatory requirements.\n\n• Consent – When you have provided clear permission for us to process your Personal Data for a specific purpose.'**
  String get myAccountPrivacyLegalBases;

  /// Main heading: Sharing information
  ///
  /// In en, this message translates to:
  /// **'Who Do We Share Your Information With?'**
  String get myAccountPrivacySectionShareTitle;

  /// Full text explaining data sharing practices
  ///
  /// In en, this message translates to:
  /// **'We require all parties who receive your Personal Data to apply appropriate security measures to protect it, in line with our policies and applicable data protection obligations. We do not allow any third-party service providers who process Personal Data on our behalf to use it for their own purposes. They are only permitted to handle your Personal Data for the specific purposes we define and strictly in accordance with our instructions.\n\nWe may also need to share certain Personal Data with other users of the Platform when you choose to engage in transactions with them. For example, if you express interest in a property listed by an Agent, relevant representatives of that Agent may require access to your Personal Data.'**
  String get myAccountPrivacyShareContent;

  /// Main heading: Data security
  ///
  /// In en, this message translates to:
  /// **'How We Keep Your Data Secure'**
  String get myAccountPrivacySectionSecurityTitle;

  /// Full text about security measures
  ///
  /// In en, this message translates to:
  /// **'We have implemented suitable security measures to protect your Personal Data from accidental loss, alteration, unauthorized access, or misuse.\n\nAccess to your Personal Data is restricted to employees and authorized personnel who require it for legitimate business purposes. All individuals with such access are bound by confidentiality obligations.\n\nWe also maintain robust procedures to detect, manage, and respond to any actual or suspected Personal Data breaches. In such cases, we take immediate steps to minimize potential impact on your privacy and cooperate with relevant regulatory authorities as required.'**
  String get myAccountPrivacySecurityContent;

  /// Main heading: User rights
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get myAccountPrivacySectionRightsTitle;

  /// Intro to list of rights
  ///
  /// In en, this message translates to:
  /// **'Depending on the applicable data protection laws and where your Personal Data is under our control, you may have the right to:'**
  String get myAccountPrivacyRightsIntro;

  /// List of user data protection rights
  ///
  /// In en, this message translates to:
  /// **'• Access — Request a copy of the Personal Data we hold about you.\n• Correction — Ask us to update or amend inaccurate or incomplete information.\n• Erasure — Request deletion of your Personal Data where it is no longer needed for its original purpose.\n• Restrict Processing — Ask us to temporarily or permanently stop processing all or part of your data.\n• Objection — Object to processing based on our legitimate interests or for direct marketing.\n• Data Portability — Request a structured, machine-readable copy of your Personal Data.\n• Withdrawal of Consent — Withdraw consent where processing is based on your permission.\n\nIf you want to exercise any of these rights, please contact us.'**
  String get myAccountPrivacyRightsList;

  /// Main heading: Marketing communications
  ///
  /// In en, this message translates to:
  /// **'Marketing Communications'**
  String get myAccountPrivacySectionMarketingTitle;

  /// Main heading: Minors protection
  ///
  /// In en, this message translates to:
  /// **'Our Privacy for Minors'**
  String get myAccountPrivacySectionMinorsTitle;

  /// Text about protection of minors
  ///
  /// In en, this message translates to:
  /// **'This Platform is not intended for use by anyone under 18. We do not knowingly collect data from minors or verify user age. If you believe a minor is using the Platform, please notify us at info@akarat.com so we can remove any associated Personal Data and prevent further access.'**
  String get myAccountPrivacyMinorsContent;

  /// Main heading: Third-party links
  ///
  /// In en, this message translates to:
  /// **'Third-Party Links'**
  String get myAccountPrivacySectionThirdPartyTitle;

  /// Text about third-party links disclaimer
  ///
  /// In en, this message translates to:
  /// **'The Platform may contain links to third-party websites or services. Akarat is not responsible for the content, availability, or privacy practices of external sites. When you leave our Platform, we encourage you to review the privacy policies of each website you visit.'**
  String get myAccountPrivacyThirdPartyContent;

  /// Main heading: Policy updates
  ///
  /// In en, this message translates to:
  /// **'Changes to the Privacy Policy'**
  String get myAccountPrivacySectionUpdatesTitle;

  /// Text about policy change procedure
  ///
  /// In en, this message translates to:
  /// **'We may update this Privacy Policy at any time, with or without prior notice. When updates occur, we will revise this page and may notify you directly in certain cases (for example, by email). All changes become effective immediately once posted.'**
  String get myAccountPrivacyUpdatesContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
