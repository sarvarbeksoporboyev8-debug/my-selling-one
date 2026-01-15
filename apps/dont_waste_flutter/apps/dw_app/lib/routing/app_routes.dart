/// Route path constants
abstract class AppRoutes {
  // Auth routes
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';

  // Main tab routes
  static const home = '/home';
  static const discover = '/discover';
  static const map = '/map';
  static const watchlist = '/watchlist';
  static const reservations = '/reservations';
  static const profile = '/profile';

  // Listing routes
  static const listingDetail = '/listing/:id';
  static String listingDetailPath(int id) => '/listing/$id';

  // Reserve/Offer routes
  static const reserve = '/listing/:id/reserve';
  static String reservePath(int id) => '/listing/$id/reserve';

  static const makeOffer = '/listing/:id/offer';
  static String makeOfferPath(int id) => '/listing/$id/offer';

  // Reservation routes
  static const reservationDetail = '/reservation/:id';
  static String reservationDetailPath(int id) => '/reservation/$id';

  // Seller routes
  static const myListings = '/my-listings';
  static const createListing = '/create-listing';
  static const editListing = '/listing/:id/edit';
  static String editListingPath(int id) => '/listing/$id/edit';

  // Profile sub-routes
  static const editProfile = '/profile/edit';
  static const settings = '/profile/settings';
  static const notifications = '/profile/notifications';

  // Search & Filter
  static const search = '/search';
  static const filters = '/filters';
}
