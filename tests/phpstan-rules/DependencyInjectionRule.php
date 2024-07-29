<?php

declare(strict_types=1);

namespace PhpStanRules;

use PhpParser\Node;
use PHPStan\Rules\Rule;
use PHPStan\Analyser\Scope;

class DependencyInjectionRule implements Rule
{
    public function getNodeType(): string
    {
        return Node\Expr\StaticCall::class;
    }

    public function processNode(Node $node, Scope $scope): array
    {
        if ($node instanceof Node\Expr\StaticCall &&
            $node->class instanceof Node\Name &&
            $node->class->toString() === 'Magento\Framework\App\ObjectManager') {
            return ['Avoid using \Magento\Framework\App\ObjectManager directly. Use dependency injection instead.'];
        }

        return [];
    }
}

