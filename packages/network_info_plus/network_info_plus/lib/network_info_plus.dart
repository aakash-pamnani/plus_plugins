// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:network_info_plus_platform_interface/network_info_plus_platform_interface.dart';

// Export enums from the platform_interface so plugin users can use them directly.
export 'package:network_info_plus_platform_interface/network_info_plus_platform_interface.dart'
    show LocationAuthorizationStatus;

export 'src/network_info_plus_linux.dart';

/// Discover network info: check WI-FI details and more.
class NetworkInfo {
  /// Constructs a singleton instance of [NetworkInfo].
  ///
  /// [NetworkInfo] is designed to work as a singleton.
  // When a second instance is created, the first instance will not be able to listen to the
  // EventChannel because it is overridden. Forcing the class to be a singleton class can prevent
  // misuse of creating a second instance from a programmer.
  factory NetworkInfo() {
    _singleton ??= NetworkInfo._();
    return _singleton!;
  }

  NetworkInfo._();

  static NetworkInfo? _singleton;

  // This is to manually endorse Dart implementations until automatic
  // registration of Dart plugins is implemented. For details see
  // https://github.com/flutter/flutter/issues/52267.
  static NetworkInfoPlatform get _platform {
    return NetworkInfoPlatform.instance;
  }

  /// Obtains the wifi name (SSID) of the connected network
  ///
  /// Please note that it DOESN'T WORK on emulators (returns null).
  ///
  /// From android 8.0 onwards the GPS must be ON (high accuracy)
  /// in order to be able to obtain the SSID.
  Future<String?> getWifiName() {
    return _platform.getWifiName();
  }

  /// Obtains the wifi BSSID of the connected network.
  ///
  /// Please note that it DOESN'T WORK on emulators (returns null).
  ///
  /// From Android 8.0 onwards the GPS must be ON (high accuracy)
  /// in order to be able to obtain the BSSID.
  Future<String?> getWifiBSSID() {
    return _platform.getWifiBSSID();
  }

  /// Obtains the IPv4 address of the connected wifi network
  Future<String?> getWifiIP() {
    return _platform.getWifiIP();
  }

  /// Obtains the IPv6 address of the connected wifi network
  Future<String?> getWifiIPv6() {
    return _platform.getWifiIPv6();
  }

  /// Obtains the submask of the connected wifi network
  Future<String?> getWifiSubmask() {
    return _platform.getWifiSubmask();
  }

  /// Obtains the gateway IP address of the connected wifi network
  Future<String?> getWifiGatewayIP() {
    return _platform.getWifiGatewayIP();
  }

  /// Obtains the broadcast of the connected wifi network
  Future<String?> getWifiBroadcast() {
    return _platform.getWifiBroadcast();
  }

  /// Request to authorize the location service (Only on iOS).
  ///
  /// This method will throw a [PlatformException] on Android.
  ///
  /// Returns a [LocationAuthorizationStatus] after user authorized or denied the location on this request.
  ///
  /// If the location information needs to be accessible all the time, set `requestAlwaysLocationUsage` to true. If user has
  /// already granted a [LocationAuthorizationStatus.authorizedWhenInUse] prior to requesting an "always" access, it will return [LocationAuthorizationStatus.denied].
  ///
  /// If the location service authorization is not determined prior to making this call, a platform standard UI of requesting a location service will pop up.
  /// This UI will only show once unless the user re-install the app to their phone which resets the location service authorization to not determined.
  ///
  /// This method is a helper to get the location authorization that is necessary for certain functionality of this plugin.
  /// It can be replaced with other permission handling code/plugin if preferred.
  /// To request location authorization, make sure to add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:
  /// * `NSLocationAlwaysAndWhenInUseUsageDescription` - describe why the app needs access to the user’s location information
  /// all the time (foreground and background). This is called _Privacy - Location Always and When In Use Usage Description_ in the visual editor.
  /// * `NSLocationWhenInUseUsageDescription` - describe why the app needs access to the user’s location information when the app is
  /// running in the foreground. This is called _Privacy - Location When In Use Usage Description_ in the visual editor.
  ///
  /// Starting from iOS 13, `getWifiBSSID` and `getWifiIP` will only work properly if:
  ///
  /// * The app uses Core Location, and has the user’s authorization to use location information.
  /// * The app uses the NEHotspotConfiguration API to configure the current Wi-Fi network.
  /// * The app has active VPN configurations installed.
  ///
  /// If the app falls into the first category, call this method before calling `getWifiBSSID` or `getWifiIP`.
  /// For example,
  /// ```dart
  /// if (Platform.isIOS) {
  ///   LocationAuthorizationStatus status = await _networkInfo.getLocationServiceAuthorization();
  ///   if (status == LocationAuthorizationStatus.notDetermined) {
  ///     status = await _networkInfo.requestLocationServiceAuthorization();
  ///   }
  ///   if (status == LocationAuthorizationStatus.authorizedAlways || status == LocationAuthorizationStatus.authorizedWhenInUse) {
  ///     wifiBSSID = await _networkInfo.getWifiName();
  ///   } else {
  ///     print('location service is not authorized, the data might not be correct');
  ///     wifiBSSID = await _networkInfo.getWifiName();
  ///   }
  /// } else {
  ///   wifiBSSID = await _networkInfo.getWifiName();
  /// }
  /// ```
  ///
  /// Ideally, a location service authorization should only be requested if the current authorization status is not determined.
  ///
  /// See also [getLocationServiceAuthorization] to obtain current location service status.
  @Deprecated(
      'Plugin users should use the permission_handler plugin to request permissions. '
      'See README.md for more details.')
  Future<LocationAuthorizationStatus> requestLocationServiceAuthorization({
    bool requestAlwaysLocationUsage = false,
  }) {
    return _platform.requestLocationServiceAuthorization(
      requestAlwaysLocationUsage: requestAlwaysLocationUsage,
    );
  }

  /// Get the current location service authorization (Only on iOS).
  ///
  /// This method will throw a [PlatformException] on Android.
  ///
  /// Returns a [LocationAuthorizationStatus].
  /// If the returned value is [LocationAuthorizationStatus.notDetermined], a subsequent [requestLocationServiceAuthorization] call
  /// can request the authorization.
  /// If the returned value is not [LocationAuthorizationStatus.notDetermined], a subsequent [requestLocationServiceAuthorization]
  /// will not initiate another request. It will instead return the "determined" status.
  ///
  /// This method is a helper to get the location authorization that is necessary for certain functionality of this plugin.
  /// It can be replaced with other permission handling code/plugin if preferred.
  ///
  /// Starting from iOS 13, `getWifiBSSID` and `getWifiIP` will only work properly if:
  ///
  /// * The app uses Core Location, and has the user’s authorization to use location information.
  /// * The app uses the NEHotspotConfiguration API to configure the current Wi-Fi network.
  /// * The app has active VPN configurations installed.
  ///
  /// If the app falls into the first category, call this method before calling `getWifiBSSID` or `getWifiIP`.
  /// For example,
  /// ```dart
  /// if (Platform.isIOS) {
  ///   LocationAuthorizationStatus status = await _networkInfo.getLocationServiceAuthorization();
  ///   if (status == LocationAuthorizationStatus.authorizedAlways || status == LocationAuthorizationStatus.authorizedWhenInUse) {
  ///     wifiBSSID = await _networkInfo.getWifiName();
  ///   } else {
  ///     print('location service is not authorized, the data might not be correct');
  ///     wifiBSSID = await _networkInfo.getWifiName();
  ///   }
  /// } else {
  ///   wifiBSSID = await _networkInfo.getWifiName();
  /// }
  /// ```
  ///
  /// See also [requestLocationServiceAuthorization] for requesting a location service authorization.
  @Deprecated(
      'Plugin users should use the permission_handler plugin to request permissions. '
      'See README.md for more details.')
  Future<LocationAuthorizationStatus> getLocationServiceAuthorization() {
    return _platform.getLocationServiceAuthorization();
  }
}
