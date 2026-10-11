enum AppRoutes {
  splash("/"),
  onBoarding("/onBoarding"),
  signUp("/signUp"),
  signIn("/signIn"),
  forgotPassword("/forgotPassword"),
  home("/home"),
  deliveryRouteMap("/deliveryRouteMap"),
  bakeryDetails("/bakeryDetails");

  final String route;

  const AppRoutes(this.route);

  static AppRoutes? fromRoute(String? route) {
    return AppRoutes.values.firstWhere(
      (e) => e.route == route,
      orElse: () => AppRoutes.splash,
    );
  }
}
