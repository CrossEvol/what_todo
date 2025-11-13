import 'package:equatable/equatable.dart';

/// Represents GitHub repository configuration for backup functionality
class GitHubConfig extends Equatable {
  final String token;
  final String owner;
  final String repo;
  final String pathPrefix;
  final String branch;

  const GitHubConfig({
    required this.token,
    required this.owner,
    required this.repo,
    required this.pathPrefix,
    required this.branch,
  });

  /// Validates that all required fields are non-empty
  bool isValid() {
    return token.isNotEmpty &&
        owner.isNotEmpty &&
        repo.isNotEmpty &&
        branch.isNotEmpty;
  }

  /// Creates an empty GitHubConfig with default values
  factory GitHubConfig.empty() {
    return const GitHubConfig(
      token: '',
      owner: '',
      repo: '',
      pathPrefix: '/',
      branch: 'master',
    );
  }

  /// Serializes the config to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'owner': owner,
      'repo': repo,
      'pathPrefix': pathPrefix,
      'branch': branch,
    };
  }

  /// Deserializes the config from a Map
  factory GitHubConfig.fromMap(Map<String, dynamic> map) {
    return GitHubConfig(
      token: map['token'] as String? ?? '',
      owner: map['owner'] as String? ?? '',
      repo: map['repo'] as String? ?? '',
      pathPrefix: map['pathPrefix'] as String? ?? '/',
      branch: map['branch'] as String? ?? 'master',
    );
  }

  /// Creates a copy of this config with the given fields replaced
  GitHubConfig copyWith({
    String? token,
    String? owner,
    String? repo,
    String? pathPrefix,
    String? branch,
  }) {
    return GitHubConfig(
      token: token ?? this.token,
      owner: owner ?? this.owner,
      repo: repo ?? this.repo,
      pathPrefix: pathPrefix ?? this.pathPrefix,
      branch: branch ?? this.branch,
    );
  }

  @override
  List<Object?> get props => [
        token,
        owner,
        repo,
        pathPrefix,
        branch,
      ];
}
