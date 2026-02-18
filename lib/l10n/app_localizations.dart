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

  /// No description provided for @language.
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

  /// Title for latest projects section (usually Dubai focused)
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

  /// Title for the project detail screen / app bar
  ///
  /// In en, this message translates to:
  /// **'Project Detail'**
  String get projectDetail;

  /// Message shown when project data is missing or null
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Dialog title in bottom nav favorites when not logged in
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// Message explaining why login is needed to view favorites
  ///
  /// In en, this message translates to:
  /// **'Please login to access your favorites.'**
  String get loginToAccessFavorites;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Shown when user is not logged in on profile card
  ///
  /// In en, this message translates to:
  /// **'Welcome! Login / Sign up'**
  String get welcomeLoginSignUp;

  /// Label for user profile (e.g. in header or menu)
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Menu item / screen title for Find My Agent page
  ///
  /// In en, this message translates to:
  /// **'Find My Agent'**
  String get findMyAgent;

  /// Menu item for favorite properties
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Screen title
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

  /// Menu item for support / contact page
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

  /// Message shown when not logged in
  ///
  /// In en, this message translates to:
  /// **'You need to log in to view your favorite properties.'**
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

  /// Message shown when user tries to edit profile without being logged in
  ///
  /// In en, this message translates to:
  /// **'Please login to edit your profile.'**
  String get loginToEditProfile;

  /// Shown when user tries authenticated action without login
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

  /// Hint text for the search field on home screen
  ///
  /// In en, this message translates to:
  /// **'Search for a locality, area or city'**
  String get homeSearchLocationHint;

  /// Label for property for rent section
  ///
  /// In en, this message translates to:
  /// **'Property For Rent'**
  String get homePropertyForRent;

  /// Label for property for sale section
  ///
  /// In en, this message translates to:
  /// **'Property For Sale'**
  String get homePropertyForSale;

  /// Label for off-plan properties section
  ///
  /// In en, this message translates to:
  /// **'Off-Plan Properties'**
  String get homeOffPlanProperties;

  /// Label for commercial properties section
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get homeCommercial;

  /// Label for villas section
  ///
  /// In en, this message translates to:
  /// **'Villas'**
  String get homeVilla;

  /// Label for apartments section
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get homeApartment;

  /// Subtitle in Home screen New Projects area
  ///
  /// In en, this message translates to:
  /// **'Discover more about the UAE real estate market'**
  String get homeDiscoverUaeRealEstate;

  /// Sorting option – newest first
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get homeSortNewest;

  /// Sorting option – featured listings
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get homeSortFeatured;

  /// Sorting option – price low to high
  ///
  /// In en, this message translates to:
  /// **'Price (Low)'**
  String get homeSortPriceLow;

  /// Sorting option – price high to low
  ///
  /// In en, this message translates to:
  /// **'Price (High)'**
  String get homeSortPriceHigh;

  /// App bar title on the support screen
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get myAccountSupportTitle;

  /// Subtitle shown on the support screen
  ///
  /// In en, this message translates to:
  /// **'Ask us anything?'**
  String get myAccountSupportSubTitle;

  /// Label for name input field on support screen
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get myAccountSupportNameLabel;

  /// Label for email input field on support screen
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get myAccountSupportEmailLabel;

  /// Label for phone input field on support screen
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get myAccountSupportPhoneLabel;

  /// Label for subject input field on support screen
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get myAccountSupportSubjectLabel;

  /// Label for message input field on support screen
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get myAccountSupportMessageLabel;

  /// Text on the submit button of support form
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get myAccountSupportSubmitButtonText;

  /// Generic prefix for empty required field validation
  ///
  /// In en, this message translates to:
  /// **'Please enter'**
  String get myAccountSupportValidationEnterText;

  /// Validation when phone field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter Phone Number'**
  String get myAccountSupportValidationEnterPhone;

  /// Validation when phone contains non-digits
  ///
  /// In en, this message translates to:
  /// **'Phone number must contain digits only'**
  String get myAccountSupportValidationPhoneDigitsOnly;

  /// Validation for incorrect phone length; {length} and {country} are placeholders
  ///
  /// In en, this message translates to:
  /// **'Phone number must be {length} digits for {country}'**
  String myAccountSupportValidationPhoneLength(Object length, Object country);

  /// Generic required field error. {label} = field name
  ///
  /// In en, this message translates to:
  /// **'Please enter {label}'**
  String myAccountSupportValidationRequired(Object label);

  /// Validation when email field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter Email'**
  String get myAccountSupportValidationEmailRequired;

  /// Validation when email format is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get myAccountSupportValidationEmailInvalid;

  /// AppBar title of Find Agent screen
  ///
  /// In en, this message translates to:
  /// **'Find My Agent'**
  String get findAgentTitle;

  /// Tab label for individual agents
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agentsTab;

  /// Tab label for real estate agencies/companies
  ///
  /// In en, this message translates to:
  /// **'Agencies'**
  String get agencyTab;

  /// Hint in agent search field
  ///
  /// In en, this message translates to:
  /// **'Enter location or agent name'**
  String get searchAgentHint;

  /// Hint in agency search field
  ///
  /// In en, this message translates to:
  /// **'Enter location or agency name'**
  String get searchAgencyHint;

  /// Section title above featured agents list
  ///
  /// In en, this message translates to:
  /// **'Featured Agents'**
  String get featuredAgents;

  /// Section title above featured agencies list
  ///
  /// In en, this message translates to:
  /// **'Featured Agencies'**
  String get featuredAgencies;

  /// Description text below Featured Agents title
  ///
  /// In en, this message translates to:
  /// **'Explore agents with a proven track record of high response rates and authentic listings.'**
  String get featuredAgentsDescription;

  /// Description text below Featured Agencies title
  ///
  /// In en, this message translates to:
  /// **'Explore agencies with a proven track record of high response rates and authentic listings.'**
  String get featuredAgenciesDescription;

  /// Message when agent search returns empty
  ///
  /// In en, this message translates to:
  /// **'No agents found'**
  String get noAgentsFound;

  /// Message when agency search returns empty
  ///
  /// In en, this message translates to:
  /// **'No agencies found'**
  String get noAgenciesFound;

  /// General empty state message when list is empty
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get noResults;

  /// Button label to clear all filters and search
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetFilters;

  /// Error message when fetching list of nationalities fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load nationalities'**
  String get failedToLoadNationalities;

  /// Error message when fetching list of supported languages fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load languages'**
  String get failedToLoadLanguages;

  /// Title of the About tab in agent detail screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get agentAboutTitle;

  /// Label above agent description text
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get agentDescriptionLabel;

  /// Shown when agent has no about text
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get agentNoDescription;

  /// Label for agent's expertise section
  ///
  /// In en, this message translates to:
  /// **'Expertise'**
  String get agentExpertiseLabel;

  /// Label for agent's service areas
  ///
  /// In en, this message translates to:
  /// **'Service Areas'**
  String get agentServiceAreasLabel;

  /// Label for agent's languages
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get agentLanguagesLabel;

  /// Label for agent's years of experience
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get agentExperienceLabel;

  /// Suffix after number of years in experience
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get agentExperienceYears;

  /// Label for Broker Registration Number
  ///
  /// In en, this message translates to:
  /// **'BRN'**
  String get agentBrnLabel;

  /// Title of Reviews tab in agent detail
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get agentReviewsTitle;

  /// Placeholder title for not-yet-implemented features
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoonTitle;

  /// Message shown in reviews tab under Coming Soon
  ///
  /// In en, this message translates to:
  /// **'Agent reviews will be available here soon'**
  String get agentReviewsComingSoonMessage;

  /// Label on email button in agent detail bottom bar
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get agentContactEmail;

  /// Label on call button in agent detail bottom bar
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get agentContactCall;

  /// Label on WhatsApp button in agent detail bottom bar
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get agentContactWhatsApp;

  /// Tab label for agent's listed properties
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get propertiesTab;

  /// Tab label for agent reviews
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTab;

  /// Label before agent's languages list
  ///
  /// In en, this message translates to:
  /// **'Speaks: '**
  String get agentSpeaksLabel;

  /// Tag showing number of sale properties
  ///
  /// In en, this message translates to:
  /// **'{count} Sale'**
  String agentSaleTag(Object count);

  /// Tag showing number of rent properties
  ///
  /// In en, this message translates to:
  /// **'{count} Rent'**
  String agentRentTag(Object count);

  /// Fallback when data is missing (e.g. languages)
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// Text showing number of properties an agent has
  ///
  /// In en, this message translates to:
  /// **'{count} Properties'**
  String agentPropertiesCount(Object count);

  /// Label showing number of properties for an agency
  ///
  /// In en, this message translates to:
  /// **'{count} Properties'**
  String propertiesCountLabel(Object count);

  /// Title of the registration screen app bar
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
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
  /// **'Email'**
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

  /// Password rule - minimum length
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Characters;

  /// Password rule - uppercase required
  ///
  /// In en, this message translates to:
  /// **'One uppercase letter'**
  String get oneUppercaseLetter;

  /// Password rule - digit required
  ///
  /// In en, this message translates to:
  /// **'One number'**
  String get oneNumber;

  /// Password rule - special character required
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
  /// **'By signing up, you agree to our '**
  String get bySigningUpAgreeTo;

  /// Conjunction in terms/privacy sentence
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// Text before login link
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Login link text
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get loginHere;

  /// Hint text in country code picker search field
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountryHint;

  /// Validation error - missing first name
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get errorFirstNameRequired;

  /// Validation error - missing last name
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get errorLastNameRequired;

  /// Validation error - missing email
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get errorEmailRequired;

  /// Validation error - bad email format
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get errorInvalidEmail;

  /// Validation error - missing phone
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get errorPhoneRequired;

  /// Validation error - invalid phone characters
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get errorInvalidPhoneDigits;

  /// Validation error - wrong phone length
  ///
  /// In en, this message translates to:
  /// **'Phone number must be {length} digits for {countryCode}'**
  String errorPhoneLength(Object length, Object countryCode);

  /// Validation error - missing password
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get errorPasswordRequired;

  /// Validation error - password too weak
  ///
  /// In en, this message translates to:
  /// **'Password does not meet requirements'**
  String get errorPasswordRequirements;

  /// Validation error - missing confirmation
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get errorConfirmPasswordRequired;

  /// Validation error - passwords mismatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordsNotMatch;

  /// Success message after sending OTP / registration
  ///
  /// In en, this message translates to:
  /// **'OTP sent. Please check your email.'**
  String get otpSentMessage;

  /// Timeout error message
  ///
  /// In en, this message translates to:
  /// **'Registration timed out. Please try again.'**
  String get registrationTimedOut;

  /// Error when email is already taken
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please login or use Forgot Password.'**
  String get emailAlreadyRegistered;

  /// Rate limit error message
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a minute and try again.'**
  String get tooManyAttempts;

  /// Platform check failure
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In not supported on this platform.'**
  String get googleSignInNotSupported;

  /// Firebase returned no user after credential sign-in
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. No user account was created.'**
  String get firebaseUserNullAfterSignIn;

  /// Error getting Firebase ID token
  ///
  /// In en, this message translates to:
  /// **'Failed to get authentication token.'**
  String get failedToGetFirebaseIdToken;

  /// User-facing error when account is deleted/inactive after Google sign-in
  ///
  /// In en, this message translates to:
  /// **'This account has been deleted or deactivated.\nPlease contact support to reactivate or use a different email.'**
  String get accountDeletedOrInactiveContactSupport;

  /// Technical error when backend token is null/empty or account deleted
  ///
  /// In en, this message translates to:
  /// **'This account has been deleted or token is missing.'**
  String get accountDeletedOrTokenMissing;

  /// User-friendly message when /login-google returns HTML instead of JSON
  ///
  /// In en, this message translates to:
  /// **'Invalid response from server. Please try again later.'**
  String get nonJsonFromLoginGoogle;

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

  /// Main welcome title on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Akarat!'**
  String get welcomeToAkarat;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @notRegisteredYet.
  ///
  /// In en, this message translates to:
  /// **'Not registered yet?'**
  String get notRegisteredYet;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createNewAccount;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// Generic 'please enter' validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}'**
  String pleaseEnterField(Object field);

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmailAddress;

  /// Error when backend login OK but no token returned
  ///
  /// In en, this message translates to:
  /// **'Login succeeded but token missing.'**
  String get loginSucceededButTokenMissing;

  /// Generic fallback server error
  ///
  /// In en, this message translates to:
  /// **'Server error. Try again.'**
  String get serverErrorTryAgain;

  /// 401 Unauthorized - wrong credentials
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidEmailOrPassword;

  /// 422 validation failed generic message
  ///
  /// In en, this message translates to:
  /// **'Validation error.'**
  String get validationError;

  /// Generic server error with status code
  ///
  /// In en, this message translates to:
  /// **'Server error ({code}).'**
  String serverErrorWithCode(Object code);

  /// Catch-all network / timeout / connection error
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get networkErrorCheckConnection;

  /// Google login returned no/invalid token
  ///
  /// In en, this message translates to:
  /// **'Account inactive or deleted.'**
  String get accountInactiveOrDeleted;

  /// Google auth response missing idToken
  ///
  /// In en, this message translates to:
  /// **'Google ID token missing.'**
  String get googleIdTokenMissing;

  /// Credential sign-in returned no user
  ///
  /// In en, this message translates to:
  /// **'Firebase sign-in failed.'**
  String get firebaseSignInFailed;

  /// getIdToken() failed
  ///
  /// In en, this message translates to:
  /// **'Failed to get Firebase token.'**
  String get failedToGetFirebaseToken;

  /// Backend returned HTML instead of JSON (dev message)
  ///
  /// In en, this message translates to:
  /// **'Non-JSON from /login-google (HTML). Check API_BASE_URL (QA vs PROD) and route.'**
  String get nonJsonFromGoogleLogin;

  /// AppBar title for favorites screen
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// Confirmation dialog title for clearing all contacted properties
  ///
  /// In en, this message translates to:
  /// **'Clear All Contacted Properties?'**
  String get clearAll;

  /// Dialog title when clearing favorites
  ///
  /// In en, this message translates to:
  /// **'Clear All Favorites?'**
  String get clearAllFavoritesTitle;

  /// Dialog content warning
  ///
  /// In en, this message translates to:
  /// **'This will remove all saved properties from your favorites. This action cannot be undone.'**
  String get clearAllFavoritesMessage;

  /// No description provided for @clearAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will remove all your saved alerts.'**
  String get clearAllConfirm;

  /// Snackbar when trying to clear without login
  ///
  /// In en, this message translates to:
  /// **'You are not logged in'**
  String get notLoggedInMessage;

  /// Loading message in snackbar
  ///
  /// In en, this message translates to:
  /// **'Clearing all favorites...'**
  String get clearingFavorites;

  /// Success message after clearing
  ///
  /// In en, this message translates to:
  /// **'All favorites cleared successfully'**
  String get favoritesClearedSuccess;

  /// Error message with status code
  ///
  /// In en, this message translates to:
  /// **'Failed to clear favorites: {statusCode}'**
  String failedToClearFavorites(Object statusCode);

  /// Generic error when clearing fails
  ///
  /// In en, this message translates to:
  /// **'Error clearing favorites. Check your connection.'**
  String get errorClearingFavorites;

  /// Button to go to login screen
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Message when favorites list is empty
  ///
  /// In en, this message translates to:
  /// **'No favorite properties yet'**
  String get noFavoritesYet;

  /// Instruction for empty favorites state
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any property to save it here'**
  String get tapHeartToSave;

  /// Button to go to home screen when no favorites
  ///
  /// In en, this message translates to:
  /// **'Browse Properties'**
  String get browseProperties;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Fallback error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// AppBar title
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformationTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// Label/hint for the email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Validator message when email field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// Helper text under email field
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotBeChanged;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Change password (optional)'**
  String get changePasswordOptional;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// Helper text
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep your current password'**
  String get newPasswordHelper;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordLabel;

  /// No description provided for @confirmNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the new password'**
  String get confirmNewPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password (required to change)'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get currentPasswordRequired;

  /// Save profile button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete your account'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'You will lose all your saved alerts,\nsaved properties, etc.'**
  String get deleteAccountDialogMessage;

  /// Red delete button in dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirm;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get sessionExpired;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// Generic fallback error
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// Main heading of the forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordTitle;

  /// Explanation text below the title
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get forgotPasswordSubtitle;

  /// Text on the main submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// Text on the back button/link
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Validator message for invalid email pattern
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// Success message when reset link is sent (fallback if backend message missing)
  ///
  /// In en, this message translates to:
  /// **'Reset email sent successfully.'**
  String get resetEmailSent;

  /// Generic error when status != 200 (fallback)
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email.'**
  String get failedToSendResetEmail;

  /// Catch-all network/error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// Title of the language change dialog
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Instruction text shown on iOS when changing language
  ///
  /// In en, this message translates to:
  /// **'To change your Akarat app language, follow the steps below:'**
  String get changeLanguageInstruction;

  /// No description provided for @stepOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'1. Open Settings.'**
  String get stepOpenSettings;

  /// No description provided for @stepSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'2. Tap Language to make a selection.'**
  String get stepSelectLanguage;

  /// Button label to open device settings (iOS)
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Label for English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Label for Arabic language option
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Label for Turkish language option
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// Title of the screen when creating a new alert
  ///
  /// In en, this message translates to:
  /// **'Create Alert'**
  String get createAlertTitle;

  /// Title of the screen when editing an existing saved alert
  ///
  /// In en, this message translates to:
  /// **'Edit Alert'**
  String get editAlertTitle;

  /// Label above the alert name input field
  ///
  /// In en, this message translates to:
  /// **'Alert Name'**
  String get alertNameLabel;

  /// Placeholder/hint text inside the alert name input field
  ///
  /// In en, this message translates to:
  /// **'Alert Name'**
  String get alertNameHint;

  /// Validation error message when alert name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get alertNameRequired;

  /// Label above the time period (frequency) dropdown
  ///
  /// In en, this message translates to:
  /// **'Time Period'**
  String get timePeriodLabel;

  /// Label above the purpose field (Rent / Buy)
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purposeLabel;

  /// Label above the property type dropdown / selector
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get propertyTypeLabel;

  /// Option meaning 'any property type'
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get propertyTypeAny;

  /// Button text when creating a new alert
  ///
  /// In en, this message translates to:
  /// **'Save Alert'**
  String get saveAlert;

  /// Button text when editing / updating an existing alert
  ///
  /// In en, this message translates to:
  /// **'Update Alert'**
  String get updateAlert;

  /// Button text shown while the save/update operation is in progress
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingAlert;

  /// Success message shown after creating a new alert
  ///
  /// In en, this message translates to:
  /// **'Alert saved successfully'**
  String get alertSaved;

  /// Success message shown after updating an existing alert
  ///
  /// In en, this message translates to:
  /// **'Alert updated successfully'**
  String get alertUpdated;

  /// Generic error message when save/update fails (e.g. server error)
  ///
  /// In en, this message translates to:
  /// **'Failed to save alert. Please try again.'**
  String get alertSaveFailed;

  /// Number of saved alerts
  ///
  /// In en, this message translates to:
  /// **'({count})'**
  String savedAlertsCount(Object count);

  /// Error message in error view (with dynamic error detail)
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorTitleWithMessage(Object message);

  /// Button label to retry loading data
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Subtitle/description under title
  ///
  /// In en, this message translates to:
  /// **'Manage your saved property alerts here'**
  String get manageYourSavedPropertyAlerts;

  /// No description provided for @youHaventSavedAnyAlertsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven’t saved any alerts yet.'**
  String get youHaventSavedAnyAlertsYet;

  /// No description provided for @createAlert.
  ///
  /// In en, this message translates to:
  /// **'Create Alert'**
  String get createAlert;

  /// Label above frequency selector in alert card
  ///
  /// In en, this message translates to:
  /// **'Receive updates'**
  String get receiveUpdates;

  /// Prefix for relative time in alert card
  ///
  /// In en, this message translates to:
  /// **'Created {time}'**
  String createdTimeAgo(Object time);

  /// Relative time < 1 minute
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Relative time in minutes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 minute ago} other{{count} minutes ago}}'**
  String minutesAgo(num count);

  /// Relative time in hours
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(num count);

  /// Relative time in days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day ago} other{{count} days ago}}'**
  String daysAgo(num count);

  /// No description provided for @deleteAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Saved Alert?'**
  String get deleteAlertTitle;

  /// No description provided for @deleteAlertConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to delete this saved alert?'**
  String get deleteAlertConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Dialog title when clearing all
  ///
  /// In en, this message translates to:
  /// **'Clear All Saved Alerts?'**
  String get clearAllTitle;

  /// Snackbar after single delete
  ///
  /// In en, this message translates to:
  /// **'Alert deleted'**
  String get alertDeleted;

  /// Snackbar after clear all
  ///
  /// In en, this message translates to:
  /// **'All alerts deleted'**
  String get allAlertsDeleted;

  /// Dialog message in bottom nav
  ///
  /// In en, this message translates to:
  /// **'Please login to access favorites.'**
  String get pleaseLoginToAccessFavorites;

  /// No description provided for @loginRequiredToCreateAlerts.
  ///
  /// In en, this message translates to:
  /// **'Login required to create alerts.'**
  String get loginRequiredToCreateAlerts;

  /// Tooltip on info icon
  ///
  /// In en, this message translates to:
  /// **'How to remove saved alerts'**
  String get howToRemoveSavedAlerts;

  /// No description provided for @howToRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Remove'**
  String get howToRemoveTitle;

  /// No description provided for @howToRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Swipe left on any property to remove it from your contacted list'**
  String get howToRemoveMessage;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// Pagination text
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageCurrentOfTotal(Object current, Object total);

  /// Snackbar after successfully creating new alert
  ///
  /// In en, this message translates to:
  /// **'Alert created'**
  String get alertCreated;

  /// Dialog title when email launch fails
  ///
  /// In en, this message translates to:
  /// **'Email not available'**
  String get emailNotAvailable;

  /// No description provided for @noEmailAppConfigured.
  ///
  /// In en, this message translates to:
  /// **'No email app is configured on this device. Please add a mail account first.'**
  String get noEmailAppConfigured;

  /// Generic OK button in dialogs
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Frequency option for alerts - every hour
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get hourly;

  /// Frequency option for alerts - every day
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Frequency option for alerts - every week
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Frequency option for alerts - every month
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Fallback when alert has no name
  ///
  /// In en, this message translates to:
  /// **'Unnamed Alert'**
  String get unnamedAlert;

  /// No description provided for @purposeRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get purposeRent;

  /// No description provided for @purposeBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get purposeBuy;

  /// Label for property type dropdown/filter
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get alertPropertyType;

  /// Main large heading at the top of the page
  ///
  /// In en, this message translates to:
  /// **'About Akarat'**
  String get aboutUs_hero_title;

  /// Tagline / subtitle shown right below the hero title (usually in red)
  ///
  /// In en, this message translates to:
  /// **'Built for Trust. Designed for the Future.'**
  String get aboutUs_hero_subtitle;

  /// First paragraph in the introduction section
  ///
  /// In en, this message translates to:
  /// **'Akarat is not just a real estate platform — it\'s a smarter way to connect people with properties in the UAE.'**
  String get aboutUs_intro_paragraph_1;

  /// Second paragraph in the introduction section
  ///
  /// In en, this message translates to:
  /// **'We bring together verified listings, powerful tech, and a user-first approach to help everyone succeed with confidence.'**
  String get aboutUs_intro_paragraph_2;

  /// Label on the prominent blue button after the main image
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get aboutUs_get_started_button;

  /// First part of 'What We Offer' heading (black)
  ///
  /// In en, this message translates to:
  /// **'What We'**
  String get aboutUs_features_heading_part1;

  /// Second part of 'What We Offer' heading (red)
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get aboutUs_features_heading_part2;

  /// Small description under the 'What We Offer' heading
  ///
  /// In en, this message translates to:
  /// **'Smart tools and verified listings tailored for real estate success.'**
  String get aboutUs_features_subtitle;

  /// Title of Verified Listings feature card in grid
  ///
  /// In en, this message translates to:
  /// **'Verified Listings'**
  String get aboutUs_feature_verified_listings_title;

  /// Short description for Verified Listings feature card
  ///
  /// In en, this message translates to:
  /// **'100% verified properties to build trust and transparency.'**
  String get aboutUs_feature_verified_listings_desc;

  /// Title of Smart Filters feature card in grid
  ///
  /// In en, this message translates to:
  /// **'Smart Filters'**
  String get aboutUs_feature_smart_filters_title;

  /// Short description for Smart Filters feature card
  ///
  /// In en, this message translates to:
  /// **'Advanced location & lifestyle filters to refine your search.'**
  String get aboutUs_feature_smart_filters_desc;

  /// Title of Agent Dashboard feature card in grid
  ///
  /// In en, this message translates to:
  /// **'Agent Dashboard'**
  String get aboutUs_feature_agent_dashboard_title;

  /// Short description for Agent Dashboard feature card
  ///
  /// In en, this message translates to:
  /// **'Track listing views, leads, and marketing performance.'**
  String get aboutUs_feature_agent_dashboard_desc;

  /// Title of Off-plan Projects feature card in grid
  ///
  /// In en, this message translates to:
  /// **'Off-plan Projects'**
  String get aboutUs_feature_offplan_projects_title;

  /// Short description for Off-plan Projects feature card
  ///
  /// In en, this message translates to:
  /// **'Showcase upcoming developments with dedicated visibility.'**
  String get aboutUs_feature_offplan_projects_desc;

  /// Title of Web & App Access feature card in grid
  ///
  /// In en, this message translates to:
  /// **'Web & App Access'**
  String get aboutUs_feature_web_app_access_title;

  /// Short description for Web & App Access feature card
  ///
  /// In en, this message translates to:
  /// **'Seamless browsing experience online and via mobile.'**
  String get aboutUs_feature_web_app_access_desc;

  /// Title of Growth Tools feature card in grid
  ///
  /// In en, this message translates to:
  /// **'Growth Tools'**
  String get aboutUs_feature_growth_tools_title;

  /// Short description for Growth Tools feature card
  ///
  /// In en, this message translates to:
  /// **'Marketing and data insights to boost your brand and reach.'**
  String get aboutUs_feature_growth_tools_desc;

  /// Main heading of the audience section
  ///
  /// In en, this message translates to:
  /// **'Our Audience'**
  String get aboutUs_audience_heading;

  /// Subtitle under Our Audience heading
  ///
  /// In en, this message translates to:
  /// **'We proudly serve the full real estate ecosystem'**
  String get aboutUs_audience_subtitle;

  /// Pill / chip for property investors
  ///
  /// In en, this message translates to:
  /// **'💼 Property Investors'**
  String get aboutUs_audience_pill_investors;

  /// Pill / chip for agents and agencies
  ///
  /// In en, this message translates to:
  /// **'👨‍💼 Agents & Agencies'**
  String get aboutUs_audience_pill_agents;

  /// Pill / chip for relocation services
  ///
  /// In en, this message translates to:
  /// **'🚚 Relocation Services'**
  String get aboutUs_audience_pill_relocation;

  /// Pill / chip for developers and brokers
  ///
  /// In en, this message translates to:
  /// **'🏗️ Developers & Brokers'**
  String get aboutUs_audience_pill_developers;

  /// Pill / chip for home buyers and tenants
  ///
  /// In en, this message translates to:
  /// **'🏠 Home Buyers & Tenants'**
  String get aboutUs_audience_pill_buyers;

  /// Red title above the Our Story section
  ///
  /// In en, this message translates to:
  /// **'Our Story'**
  String get aboutUs_story_heading;

  /// Large centered title in Our Story section
  ///
  /// In en, this message translates to:
  /// **'We started Akarat with one goal'**
  String get aboutUs_story_main_title;

  /// First paragraph in Our Story
  ///
  /// In en, this message translates to:
  /// **'To remove the frustration from property search and marketing by delivering real listings, real tools, and real results.'**
  String get aboutUs_story_paragraph_1;

  /// Second paragraph in Our Story
  ///
  /// In en, this message translates to:
  /// **'What began as a mission to bring clarity and trust to the real estate market has grown into a fully-featured platform trusted across the UAE.'**
  String get aboutUs_story_paragraph_2;

  /// Big number for international clients statistic
  ///
  /// In en, this message translates to:
  /// **'600 +'**
  String get aboutUs_story_stat_clients_number;

  /// Label below clients statistic number
  ///
  /// In en, this message translates to:
  /// **'International clients'**
  String get aboutUs_story_stat_clients_label;

  /// Big number for offices statistic
  ///
  /// In en, this message translates to:
  /// **'40 +'**
  String get aboutUs_story_stat_offices_number;

  /// Label below offices statistic number
  ///
  /// In en, this message translates to:
  /// **'Offices around the world'**
  String get aboutUs_story_stat_offices_label;

  /// First part of rich text heading before explore cards
  ///
  /// In en, this message translates to:
  /// **'Explore the Top Features of'**
  String get aboutUs_explore_heading_part1;

  /// Red title above Who We Serve section
  ///
  /// In en, this message translates to:
  /// **'Our services'**
  String get aboutUs_services_heading;

  /// Large title above service cards
  ///
  /// In en, this message translates to:
  /// **'Who We Serve'**
  String get aboutUs_services_subheading;

  /// Intro text before the list of service cards
  ///
  /// In en, this message translates to:
  /// **'Find your ideal home through our verified listings, updated in real time to ensure accuracy and trust.'**
  String get aboutUs_services_intro;

  /// Title of first longer explore card
  ///
  /// In en, this message translates to:
  /// **'Verified Listings'**
  String get aboutUs_explore_verified_listings_title;

  /// Description of first longer explore card
  ///
  /// In en, this message translates to:
  /// **'Every listing is manually reviewed and verified for authenticity, price accuracy, and availability.'**
  String get aboutUs_explore_verified_listings_desc;

  /// Title of second explore card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Smart Location Search'**
  String get aboutUs_explore_smart_location_title;

  /// Description of second explore card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Discover properties by area, community, landmark, or lifestyle preference using our intelligent filters.'**
  String get aboutUs_explore_smart_location_desc;

  /// Title of third explore card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Agent Dashboard'**
  String get aboutUs_explore_agent_dashboard_title;

  /// Description of third explore card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Agencies and agents get a dedicated backend to track leads, views, and property performance.'**
  String get aboutUs_explore_agent_dashboard_desc;

  /// Title of first animated service card
  ///
  /// In en, this message translates to:
  /// **'Home Buyers & Renters'**
  String get aboutUs_service_card_buyers_title;

  /// Description of first service card
  ///
  /// In en, this message translates to:
  /// **'Explore verified listings with real-time updates'**
  String get aboutUs_service_card_buyers_desc;

  /// Title of second animated service card
  ///
  /// In en, this message translates to:
  /// **'Real Estate Agents & Agencies'**
  String get aboutUs_service_card_agents_title;

  /// Description of second service card
  ///
  /// In en, this message translates to:
  /// **'Get leads, promote listings, and build your brand'**
  String get aboutUs_service_card_agents_desc;

  /// Title of third animated service card
  ///
  /// In en, this message translates to:
  /// **'Developers'**
  String get aboutUs_service_card_developers_title;

  /// Description of third service card
  ///
  /// In en, this message translates to:
  /// **'Showcase off-plan properties with rich media and featured promotions'**
  String get aboutUs_service_card_developers_desc;

  /// Title of fourth animated service card
  ///
  /// In en, this message translates to:
  /// **'Investors'**
  String get aboutUs_service_card_investors_title;

  /// Description of fourth service card
  ///
  /// In en, this message translates to:
  /// **'Discover new projects and profitable opportunities'**
  String get aboutUs_service_card_investors_desc;

  /// Title of fifth animated service card
  ///
  /// In en, this message translates to:
  /// **'Service Providers'**
  String get aboutUs_service_card_providers_title;

  /// Description of fifth service card
  ///
  /// In en, this message translates to:
  /// **'Advertise moving, interior, mortgage & legal services'**
  String get aboutUs_service_card_providers_desc;

  /// Email address shown in the dark footer at the bottom
  ///
  /// In en, this message translates to:
  /// **'info@akarat.com'**
  String get aboutUs_footer_email;

  /// Label on red button inside explore cards
  ///
  /// In en, this message translates to:
  /// **'Start a project'**
  String get aboutUs_start_project_button;

  /// Title of dialog shown when tapping favorites without login
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get aboutUs_login_dialog_title;

  /// Main message in the login required dialog
  ///
  /// In en, this message translates to:
  /// **'Please login to access favorites.'**
  String get aboutUs_login_dialog_message;

  /// Cancel button in login dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get aboutUs_login_dialog_cancel;

  /// Login button in login dialog
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get aboutUs_login_dialog_login;

  /// Large bold title text above the service cards section in About Us screen, reads 'Who We Serve'
  ///
  /// In en, this message translates to:
  /// **'Who We Serve'**
  String get aboutUs_services_whoWeServe_title;

  /// Title of first explore card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Verified Listings'**
  String get aboutUs_explore_verified_title;

  /// Description of first explore card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Every listing is manually reviewed and verified for authenticity, price accuracy, and availability.'**
  String get aboutUs_explore_verified_desc;

  /// Title of first service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Home Buyers & Renters'**
  String get aboutUs_service_buyers_renters_title;

  /// Description of first service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Explore verified listings with real-time updates'**
  String get aboutUs_service_buyers_renters_desc;

  /// Title of second service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Real Estate Agents & Agencies'**
  String get aboutUs_service_agents_agencies_title;

  /// Description of second service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Get leads, promote listings, and build your brand'**
  String get aboutUs_service_agents_agencies_desc;

  /// Title of third service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Developers'**
  String get aboutUs_service_developers_title;

  /// Description of third service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Showcase off-plan properties with rich media and featured promotions'**
  String get aboutUs_service_developers_desc;

  /// Title of fourth service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Investors'**
  String get aboutUs_service_investors_title;

  /// Description of fourth service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Discover new projects and profitable opportunities'**
  String get aboutUs_service_investors_desc;

  /// Title of fifth service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Service Providers'**
  String get aboutUs_service_providers_title;

  /// Description of fifth service card in About Us screen
  ///
  /// In en, this message translates to:
  /// **'Advertise moving, interior, mortgage & legal services'**
  String get aboutUs_service_providers_desc;

  /// Brand name 'Akarat' displayed in the rich text hero heading of About Us screen (colored red)
  ///
  /// In en, this message translates to:
  /// **'Akarat'**
  String get aboutUs_hero_brand_name;

  /// Title of the contacted properties screen
  ///
  /// In en, this message translates to:
  /// **'Contacted Properties'**
  String get contactedPropertiesTitle;

  /// No description provided for @noPropertiesYet.
  ///
  /// In en, this message translates to:
  /// **'No properties contacted yet.\nStart contacting agents!'**
  String get noPropertiesYet;

  /// No description provided for @pleaseLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Please login again.'**
  String get pleaseLoginAgain;

  /// Failed to load properties with status code
  ///
  /// In en, this message translates to:
  /// **'Failed to load ({statusCode})'**
  String failedToLoad(Object statusCode);

  /// No description provided for @removing.
  ///
  /// In en, this message translates to:
  /// **'Removing...'**
  String get removing;

  /// No description provided for @propertyRemoved.
  ///
  /// In en, this message translates to:
  /// **'Property removed from contacted list'**
  String get propertyRemoved;

  /// No description provided for @failedToRemove.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove property'**
  String get failedToRemove;

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @allCleared.
  ///
  /// In en, this message translates to:
  /// **'All contacted properties cleared'**
  String get allCleared;

  /// No description provided for @failedToClearAll.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear all properties'**
  String get failedToClearAll;

  /// No description provided for @removeProperty.
  ///
  /// In en, this message translates to:
  /// **'Remove Property?'**
  String get removeProperty;

  /// Confirmation message for removing a single property
  ///
  /// In en, this message translates to:
  /// **'Remove \"{propertyTitle}\" from contacted list?'**
  String removePropertyConfirm(Object propertyTitle, Object propertyName);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Price format with AED currency
  ///
  /// In en, this message translates to:
  /// **'{price} AED'**
  String priceAed(Object price);
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
