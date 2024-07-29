<?php

declare(strict_types=1);

namespace PhpStanRules;

use PhpParser\Node;
use PHPStan\Rules\Rule;
use PHPStan\Analyser\Scope;

class PerformanceOptimizationRule implements Rule
{
    public function getNodeType(): string
    {
        return Node\Stmt\For_::class;
    }

    public function processNode(Node $node, Scope $scope): array
    {
        if ($node instanceof Node\Stmt\For_) {
            foreach ($node->stmts as $stmt) {
                if ($this->isCollectionLoad($stmt)) {
                    return ['Avoid loading collections inside loops.'];
                }
            }
        }

        return [];
    }

    private function isCollectionLoad(Node $node): bool
    {
        // Simplified example: detect collection loading
        return false;
    }
}
