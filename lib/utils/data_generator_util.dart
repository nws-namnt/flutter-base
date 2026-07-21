import 'dart:math';

final R = 6372800;

var random = Random(DateTime.now().millisecondsSinceEpoch);

// List of all male names for randomName function.
var maleNames = <String>{
  'Liam',
  'Noah',
  'William',
  'James',
  'Logan',
  'Benjamin',
  'Mason',
  'Elijah',
  'Oliver',
  'Jacob',
  'John',
  'Robert',
  'Michael',
  'David',
  'Richard',
  'Charles',
  'Joseph',
  'Thomas',
  'Owen',
  'Dylan',
  'Luke',
  'Gabriel',
  'Anthony',
  'Isaac',
  'Grayson',
  'Jack',
  'Levi',
  'Christopher',
  'Joshua',
  'Andrew',
  'Aron',
  'Jonathan',
  'Connor',
  'Nolan',
  'Nicholas',
  'Austin',
  'Evan',
  'Maverick',
  'Parker',
  'Kevin',
  'Miles',
  'Luis',
  'Justin',
  'Max',
  'Ivan',
  'Eric',
  'Blake',
  'Lincoln',
  'Ryan'
};

// List of all female names for randomName function.
var femaleNames = <String>{
  'Emma',
  'Olivia',
  'Ava',
  'Isabella',
  'Sophia',
  'Tylor',
  'Charlotte',
  'Amelia',
  'Evelyn',
  'Abigail',
  'Mary',
  'Patricia',
  'Linda',
  'Barbara',
  'Elizabeth',
  'Jennifer',
  'Maria',
  'Susan',
  'Margaret',
  'Dorothy',
  'Emily',
  'Madison',
  'Hannah',
  'Ashley',
  'Alexa',
  'Alexis',
  'Sarah',
  'Alyssa',
  'Grace',
  'Marissa',
  'Rachel',
  'Megan',
  'Kaitlyn',
  'Katherine',
  'Savannah',
  'Ella',
  'Alexandra',
  'Haley',
  'Allison',
  'Lily',
  'Stephanie',
  'Melanie',
  'Claire',
  'Nicole',
  'Kaylee',
  'Samantha'
};

var familyNames = <String>{
  'Smith',
  'Johnson',
  'Williams',
  'Jones',
  'Brown',
  'Miller',
  'Wilson',
  'Moore',
  'Taylor',
  'Anderson',
  'Jackson',
  'White',
  'Thompson',
  'Garcia',
  'Martinez',
  'Robinson',
  'Jameson'
};

// Random build parts for randomUrl function.
var path = <String>['foo', 'bar', 'buz', 'qux'];
var query = <String>['b=3', 'd=4', 'username=waldo', 'q=xyzzy'];
var fragment = <String>['here', 'there', 'near', 'above', 'below'];

/// ----------------------------------------------------------------
enum DataGenerationType {
  color,
  date,
  familyName,
  integer,
  double,
  num,
  bool,
  ipv4,
  ipv6,
  location,
  name,
  string,
  url,
  uuid;
}

extension DataGenerationExt on DataGenerationType {
  dynamic generate() => switch(this) {
    .color => randomColor(),
    .date => randomDate(),
    .familyName => randomFamilyName(),
    .integer => randomInteger(),
    .double => randomDouble(),
    .num => randomNum(),
    .bool => randomBool(),
    .ipv4 => randomIPv4(),
    .ipv6 => randomIPv6(),
    .location => randomLocation(),
    .name => randomName(),
    .string => randomString(),
    .url => randomUrl(),
    .uuid => randomUUID(),
  };

  /// Generate random color from a given model.
  ///
  /// [model] expects a value of `'rgb'`, `'hex'`, `'hsv'`,
  /// `'hsb'`, `'hsl'` or `'cmyk'` where each value
  /// represents respective color space.
  /// Hex format starts with leading hash tag sign(#).
  ///
  /// Defaults to 'rgb'.
  ///
  /// Example usage:
  /// ```dart
  ///   randomColor('rgb') // returns 'rgb(r, g, b)' where r, g and b are random
  ///                    // integers between 0 and 255, inclusive.
  ///
  ///   randomColor('hex') // returns '#XXXXXX' where each pair represents
  ///                    // r, g, b expressed in hex format.
  ///
  ///   randomColor('hsv') // hsv and hsb are same.
  ///                    // returns 'hsv(h,s,v)' where h represents hue ranges
  ///                    // 0-360 degrees, s for saturation ranges from 0-100% and
  ///                    // v/b for value/brightness ranges from 0-100%
  ///
  ///   randomColor('hsl') // returns 'hsl(h,s,l)' where h and s are same as above and
  ///                    // l for lightness or luminosity ranges from 0-100%
  ///
  ///   randomColor('cmyk')// returns 'cmyk(c,m,y,k)'
  ///                    // c for Cyan, c for Magenta, y for Yellow and k for black
  ///                    // each ranges from 0 to 1.
  ///   randomColor() == randomColor('rgb')
  /// ```
  String randomColor([String returnModel = 'rgb']) {
    switch (returnModel) {
      case 'hex':
        return '#${List<String>.generate(3, (_) => random.nextInt(255 + 1).toRadixString(16).padLeft(2, '0')).toList().join().toUpperCase()}';
      case 'rgb':
        return 'rgb(${List<int>.generate(3, (_) => random.nextInt(255 + 1)).join(', ')})';
      case 'hsv':
      case 'hsb':
      case 'hsl':
        var hs = <String>[random.nextInt(360 + 1).toString()];
        hs.add('${random.nextInt(100 + 1).toString()}%');
        hs.add('${random.nextInt(100 + 1).toString()}%');
        return '$returnModel(${hs.join(', ')})';
      case 'cmyk':
        return 'cmyk(${List<String>.generate(4, (_) => '${random.nextInt(100 + 1).toString()}%').join(', ')})';
      default:
        throw ArgumentError('Invalid color model');
    }
  }

  /// Generate random DateTime object in between two moments in time.
  ///
  /// [firstMoment] and [secondMoment] represent `DateTime` objects
  /// from which `randomDate` returns random `DateTime` object in
  /// between both moments in time. Time is represented in _localTime_.
  ///
  /// Default values are `1970-01-01 01:00:00.000`
  /// and current time(now), respectively.
  ///
  /// Returns [DateTime].
  ///
  /// Example usage:
  /// ```dart
  ///   // returns random DateTime object in between range
  ///   // `1970-01-01 01:00:00.000` and now.
  ///   randomDate()
  ///
  ///   // returns random DateTime object in between range
  ///   // `2000-00-00 00:00:00.000` and `2015-00-00 00:00:00.000`.
  ///   randomDate(DateTime(2000), DateTime(2015))
  ///
  ///   // returns random DateTime object in between range
  ///   // `1969-07-20 20:18:04.000` and `1989-11-9 00:00:00.000`.
  ///   randomDate(DateTime.parse("1969-07-20 20:18:04"), DateTime(1989, DateTime.november, 9))
  /// ```
  DateTime randomDate([DateTime? firstMoment, DateTime? secondMoment]) {
    firstMoment ??= DateTime.fromMillisecondsSinceEpoch(0);
    secondMoment ??= DateTime.now();

    secondMoment.isBefore(firstMoment)
        ? throw ArgumentError('Second DateTime '
        'moment should be after first DateTime moment.')
        : null;

    Duration difference = secondMoment.difference(firstMoment);

    return firstMoment
        .add(Duration(seconds: random.nextInt(difference.inSeconds + 1)));
  }

  /// Generate random family name.
  ///
  /// Returns `String` representing a family name.
  ///
  /// For list of names, check [familyNames](https://github.com/dinkopehar/mock_data/blob/master/assets/familyNames.md).
  ///
  /// Example usage:
  /// ```dart
  ///   randomFamilyName()  // returns family name.
  /// ```
  String randomFamilyName() =>
      familyNames.elementAt(random.nextInt(familyNames.length));

  /// Generate random integer in range from `min` to `max`, inclusive.
  ///
  /// Throws [ArgumentError] if `min` is lower than or equal to `max`.
  int randomInteger([int min = 1, int max = 10]) {
    min >= max ? throw ArgumentError('min should be lower than max') : null;

    if (min.isNegative && max.isNegative) {
      return min + random.nextInt(min.abs() - max.abs() + 1);
    } else if (min.isNegative) {
      return min + random.nextInt(min.abs() + max + 1);
    } else {
      return min + random.nextInt(max - min + 1);
    }
  }

  /// Generate a random double in range [min, max).
  /// Optionally round to [fractionDigits] decimal places.
  double randomDouble([double min = 0.0, double max = 1.0, int? fractionDigits]) {
    min >= max ? throw ArgumentError('min should be lower than max') : null;
    final value = min + random.nextDouble() * (max - min);
    if (fractionDigits == null) return value;
    return double.parse(value.toStringAsFixed(fractionDigits));
  }

  /// Generate a random num. Returns int when both bounds are int, else double.
  num randomNum([num min = 0, num max = 1]) {
    min >= max ? throw ArgumentError('min should be lower than max') : null;
    return (min is int && max is int)
        ? randomInteger(min, max)
        : randomDouble(min.toDouble(), max.toDouble());
  }

  /// Generate a random bool. [trueProbability] biases the result (0.0 - 1.0).
  bool randomBool([double trueProbability = 0.5]) =>
      random.nextDouble() < trueProbability;

  /// Generate random IPv4 address.
  ///
  /// [format] argument accepts integers in range from 0 to 255, separated
  /// by dots(`.`), which represent a group or octet in IPv4.
  /// Group can also be represented with `*`, which generates any
  /// number for particular group.
  ///
  /// Returns IP as [String].
  ///
  /// Example usage:
  /// ```dart
  ///   randomIPv4('192.168.*.*') // returns '192.168.ANY_NUMBER.ANY_NUMBER'
  ///   randomIPv4('*.168.*.*')   // returns 'ANY_NUMBER.168.ANY_NUMBER.ANY_NUMBER'
  ///   randomIPv4() == randomIPv4('*.*.*.*')
  /// ```
  String randomIPv4([String format = '*.*.*.*']) {
    var ip = format.split('.');

    if (ip.length != 4) {
      throw ArgumentError('Invalid IPv4 format - Must contain 4 groups');
    }

    var _ip = ip
        .map((s) {
      if (s == '*') {
        return '${random.nextInt(255 + 1).toString()}.';
      }

      var parsedGroup = int.tryParse(s);

      if (parsedGroup != null && parsedGroup >= 0 && parsedGroup <= 255) {
        return '$s.';
      } else {
        throw ArgumentError('Integers must be in range of 0 and 255');
      }
    })
        .toList()
        .join();

    return _ip.substring(0, _ip.length - 1);
  }

  /// Generate random IPv6 address.
  ///
  /// [format] argument accepts integers in range from 0 to 65536,
  /// separated by colons(`:`), which represent a group or hextet in IPv6.
  /// Group can also be represented with `*`, which generates any
  /// hexadecimal number of 16 bits for a particular group.
  ///
  /// Returns IP as [String].
  ///
  /// Example usage:
  /// ```dart
  ///   randomIPv6('*:e331:93bf:*:a7c9:a63:*:*')
  ///   randomIPv6('e1b3:7bae:*:3474:*:c0cc:462:c4b9')
  ///   randomIPv6() == randomIPv6('*:*:*:*:*:*:*:*')
  /// ```

  String randomIPv6([String format = '*:*:*:*:*:*:*:*']) {
    var ip = format.split(':');

    if (ip.length != 8) {
      throw ArgumentError('Invalid IPv6 format - Must contain 8 groups');
    }

    var _ip = ip
        .map((s) {
      if (s == '*') {
        return '${random.nextInt(65535 + 1).toRadixString(16).padLeft(4, '0')}:';
      }

      var parsedGroup = int.tryParse(s, radix: 16);

      if (parsedGroup != null && parsedGroup >= 0 && parsedGroup <= 65536) {
        return '${s.padLeft(4, '0')}:';
      } else {
        throw ArgumentError('Integers must be in range of 0 and 65536');
      }
    })
        .toList()
        .join();

    return _ip.substring(0, _ip.length - 1);
  }

  /// Generate random latitude longitude in `radius` from `centerLat` to `centerLon`, inclusive.
  /// If any argument is null, random location will be returned.
  Map<String, double> randomLocation(
      [double? latitude, double? longitude, int? radius]) {
    Map<String, double> location = {};

    if (latitude == null || longitude == null || radius == null) {
      location['lat'] = random.nextDouble() * 90 * (random.nextBool() ? 1 : -1);
      location['lon'] = random.nextDouble() * 180 * (random.nextBool() ? 1 : -1);
    } else {
      // Convert radius from meters to degrees
      double radiusInDegrees = radius / 111000.0;

      double u = random.nextDouble();
      double v = random.nextDouble();
      double w = radiusInDegrees * sqrt(u);
      double t = 2 * pi * v;
      double x = w * cos(t);
      double y = w * sin(t);

      // Adjust the x-coordinate for the shrinking of the east-west distances
      location['lon'] = x / cos(_toRadians(latitude)) + longitude;
      location['lat'] = y + latitude;
    }

    return location;
  }

  /// Distance between two locations calculated with Haversine formula.
  double distance(double lat1, double lon1, double lat2, double lon2) {
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    lat1 = _toRadians(lat1);
    lat2 = _toRadians(lat2);
    double a =
        pow(sin(dLat / 2), 2) + pow(sin(dLon / 2), 2) * cos(lat1) * cos(lat2);
    double c = 2 * asin(sqrt(a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Generate random first name.
  ///
  /// Returns `String` representing a first name.
  ///
  /// [gender] parameter can be set to `male` to return only
  /// male names or `female` to return only female names or `any`
  /// to return any male or any female name.
  /// Default is `any`.
  ///
  /// Throws [ArgumentError] if gender is set to anything other
  /// than _'male'_ or _'female'_ or _'any'_.
  ///
  /// For list of names, check [names](https://github.com/dinkopehar/mock_data/blob/master/assets/names.md).
  ///
  /// Example usage:
  /// ```dart
  ///   randomName()         // returns male or female name.
  ///   randomName('male')   // returns male name.
  ///   randomName('female') // returns female name.
  /// ```
  String randomName([String gender = 'any']) {
    switch (gender) {
      case 'male':
        return maleNames.elementAt(random.nextInt(maleNames.length));
      case 'female':
        return femaleNames.elementAt(random.nextInt(femaleNames.length));
      case 'any':
        var allNames = maleNames.union(femaleNames).toList();
        allNames.shuffle(random);
        return allNames
            .elementAt(random.nextInt(maleNames.length + femaleNames.length));
      default:
        throw ArgumentError('Invalid gender value');
    }
  }

  /// Generate random string.
  ///
  /// [lengthOfMockedString] defines string length. Throws [ArgumentError]
  /// if length is less than or equal to 0. Default value is 16.
  ///
  /// [include] defines set of characters that are generated for string.
  /// It can be any combination of _'a'_, _'A'_ or _'#'_.
  ///
  /// * _'a'_ represents lowercase characters.
  /// * _'A'_ represents uppercase characters.
  /// * _'#'_ represents digits, 0 to 9.
  ///
  /// Default value of [include] is _'!'_ which is equal to
  /// combination of _'aA#'_.
  ///
  /// Throws [ArgumentError] if it contains any letter other than _'a'_,
  /// _'A'_, _'#'_ or _'!'_.
  ///
  /// Example usage:
  /// ```dart
  ///   randomString(4)       // returns string of length 4 which is
  ///                       // consisted of any combination of
  ///                       // lowercase letters, uppercase letters
  ///                       // and digits.
  ///                       // Example: Dg3C, H77a, B1LK etc.
  ///   randomString(7, 'a#') // returns string of length 7 which is
  ///                       // consisted of any combination of
  ///                       // lowercase letters and digits.
  ///                       // Example: g5a6hjc, 4hn9m3e, 6dei5e2 etc.
  ///   randomString(5, '#')  // returns string of length 5 which is
  ///                       // consisted of digits.
  ///                       // Example: 51321, 74214, 06910 etc.
  /// ```
  String randomString([int lengthOfMockedString = 16, String include = '!']) {
    // Check for validity of parameters.

    lengthOfMockedString <= 0
        ? throw ArgumentError('Length must be integer '
        'higher than 0')
        : null;

    include.isEmpty ? throw ArgumentError('Empty include parameter') : null;

    include.split('').forEach((s) {
      if (!('aA#!'.contains(s))) throw ArgumentError('Invalid include parameter');
    });

    // Representation of all characters that will be generated
    // based on [include] parameter.
    var allChars = StringBuffer();

    for (var c in include.split('')) {
      if (c.contains('!')) {
        allChars.writeAll(
            ['abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'],
            '0123456789');
        break;
      }
      switch (c) {
        case 'a':
          allChars.write('abcdefghijklmnopqrstuvwxyz');
          break;
        case 'A':
          allChars.write('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
          break;
        case '#':
          allChars.write('0123456789');
          break;
        default:
          break;
      }
    }

    // Generate sequence of chars with length == [lengthOfMockedString]
    return List<String>.generate(lengthOfMockedString,
            (_) => allChars.toString()[random.nextInt(allChars.length)]).join();
  }

  /// Generate random URL from a given parameters.
  ///
  /// [scheme] represents scheme and a first build part in URL.
  /// Can be set to any string value_(http, https, ftp etc.)_.
  /// Default set to _'*'_ which represent random selection
  /// of `http` or `https`.
  ///
  /// [withPath] represents a path component, consisting
  /// of a sequence of path segments separated by a slash _(/)_.
  /// Default set to `false`.
  ///
  /// [withQuery] represents an optional query component
  /// preceded by a question mark _(?)_, containing a query string.
  /// Default set to `false`.
  ///
  /// [withFragment] represents fragment component preceded
  /// by a hash _(#)_. Usually called permalink.
  /// Default set to `false`.
  ///
  /// For complete list of url build parts, check [urlBuildParts](https://github.com/dinkopehar/mock_data/blob/master/assets/urlBuildParts.md).
  ///
  /// Example usage:
  /// ```dart
  ///   // returns URL starting with 'https' scheme
  ///   // followed by '://example.com' or '://example.net'
  ///   // followed by 1 to 4 random generated paths.
  ///   // Example: 'https://example.net/bar/qux'
  ///   randomUrl('https', true)
  ///
  ///   // returns URL starting with 'http'
  ///   // followed by '://example.com' or '://example.net'
  ///   // followed by 1 to 4 random attribute-value pairs in query
  ///   // string.
  ///   // Example: 'http://example.com?username=waldo&q=xyzzy'
  ///   randomUrl(scheme: 'http', false, true)
  /// ```
  String randomUrl(
      [String scheme = '*',
        bool withPath = false,
        withQuery = false,
        withFragment = false]) {
    var url = StringBuffer();

    switch (scheme) {
      case '*':
        url.write(random.nextInt(2) == 1 ? 'http://' : 'https://');
        break;
      default: // Any scheme
        url.write('$scheme://');
        break;
    }

    url.write(random.nextInt(2) == 1 ? 'example.com' : 'example.net');

    if (withPath) {
      url.write('/');

      // 1 to 4 paths can be generated.
      var numberOfPaths = random.nextInt(path.length) + 1;
      var paths = <String>{};

      while (paths.length < numberOfPaths) {
        paths.add(path.elementAt(random.nextInt(path.length)));
      }

      url.write(paths.join('/'));
    }

    if (withQuery) {
      url.write('?');

      // 1 to 4 queries can be generated.
      var numberOfQueries = random.nextInt(query.length) + 1;
      var queries = <String>{};

      while (queries.length < numberOfQueries) {
        queries.add(query.elementAt(random.nextInt(query.length)));
      }

      url.write(queries.join('&'));
    }

    if (withFragment) {
      url.write('#');
      url.write(fragment.elementAt(random.nextInt(fragment.length)));
    }

    return url.toString();
  }

  /// Generate version 4 based UUID.
  ///
  /// [uuidType] represents choice of different form of UUIDv4 which can be:
  /// - ver4
  /// - timestamp-first
  /// - null
  ///
  /// Defaults to `standard` if no argument is provided.
  ///
  /// Throws `ArgumentError` if argument supplied is different from possible
  /// choices.
  ///
  /// Example usage:
  /// ```dart
  ///   randomUUID()                  // return UUIDv4
  ///   randomUUID('timestamp-first') // return special type of UUIDv4 called
  ///                               // timestamp-first UUID. Useful when sorting.
  ///
  ///   randomUUID('null')            // returns null uuid.
  String randomUUID([String uuidType = 'ver4']) {
    switch (uuidType) {
      case 'ver4':
      case 'timestamp-first':
      case 'null':
        break;
      default:
        throw ArgumentError('Invalid uuidType $uuidType. Possible choices are: '
            'ver4, timestamp-first and null');
    }

    List<String> chars = List.from('0123456789abcdef'.split(''), growable: false);
    List<String> uuid =
    List.generate(36, (_) => chars.elementAt(random.nextInt(chars.length)));

    uuid[8] = '-';
    uuid[13] = '-';
    uuid[14] = '4';
    uuid[18] = '-';
    uuid[19] = '89ab'.split('').elementAt(random.nextInt(4));
    uuid[23] = '-';

    if (uuidType == 'timestamp-first') {
      uuid.setRange(0, 8,
          DateTime.now().microsecondsSinceEpoch.toRadixString(16).split(''));
    } else if (uuidType == 'null') {
      uuid = '00000000-0000-0000-0000-000000000000'.split('');
    }

    return uuid.join('');
  }
}

/// Generate a list of [length] items of type [T] using [generator].
List<T> randomList<T>(int length, T Function(int index) generator) {
  length < 0 ? throw ArgumentError('length cannot be negative') : null;
  return List<T>.generate(length, generator);
}



