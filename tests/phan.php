<?php

return [
    'minimum_target_php_version' => '7.4',
    'target_php_version' => null,

    'directory_list' => [
        '/var/www/html/app/code',
        '/var/www/html/vendor/magento',
        '/var/www/html/vendor/phpunit',
        '/var/www/html/vendor/symfony/console',
    ],

    'exclude_file_regex' => '@^vendor/.*/(tests?|Tests?|test|Test)/@',
    'exclude_analysis_directory_list' => [
        '/var/www/html/vendor/',
        '/var/www/html/app/code/Magento/',
    ],

    'minimum_severity' => 1,

    'plugins' => [
        'AlwaysReturnPlugin',      // Ensures that methods return the expected types
        'DuplicateArrayKeyPlugin', // Checks for duplicate array keys
        'PregRegexCheckerPlugin',  // Validates regular expressions in preg_* functions
        'PHPUnitNotDeadCodePlugin',// Ensures PHPUnit tests do not contain dead code
        'UnknownElementTypePlugin',// Finds unknown element types in DocBlocks
    ],

    'analyze_signature_compatibility' => true,
    'backward_compatibility_checks' => true,
    'unused_variable_detection' => true,
];
