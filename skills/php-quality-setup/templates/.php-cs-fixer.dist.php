<?php

declare(strict_types=1);

$finder = (new PhpCsFixer\Finder())
    ->in([__DIR__ . '/src', __DIR__ . '/tests'])
    ->ignoreVCSIgnored(true);

return (new PhpCsFixer\Config())
    ->setRiskyAllowed(true)
    ->setRules([
        '@PER-CS2.0' => true,
        '@PER-CS2.0:risky' => true,
        'declare_strict_types' => true,
        'final_class' => true,
        'strict_comparison' => true,
        'strict_param' => true,
        'date_time_immutable' => true,
        'modernize_types_casting' => true,
        'no_unused_imports' => true,
        'ordered_imports' => ['imports_order' => ['class', 'function', 'const']],
        'global_namespace_import' => ['import_classes' => true, 'import_constants' => false, 'import_functions' => false],
        'no_superfluous_elseif' => true,
        'no_useless_else' => true,
        'no_multiple_statements_per_line' => true,
        'blank_line_before_statement' => ['statements' => ['return', 'throw', 'try', 'yield']],
        'class_attributes_separation' => ['elements' => ['const' => 'one', 'method' => 'one', 'property' => 'one']],
        'no_superfluous_phpdoc_tags' => ['remove_inheritdoc' => true],
        'phpdoc_trim' => true,
        'protected_to_private' => true,
        'self_accessor' => true,
        'trailing_comma_in_multiline' => ['elements' => ['arguments', 'arrays', 'match', 'parameters']],
    ])
    ->setFinder($finder);
