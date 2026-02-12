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
