<?php

declare(strict_types=1);

namespace PhpStanRules;

use PhpParser\Node;
use PHPStan\Rules\Rule;
use PHPStan\Analyser\Scope;

class EventObserverConsistencyRule implements Rule
{
    public function getNodeType(): string
    {
        return Node\Stmt\ClassMethod::class;
    }

    public function processNode(Node $node, Scope $scope): array
    {
        if ($node instanceof Node\Stmt\ClassMethod && $this->isObserverMethod($node)) {
            $expectedParams = ['observer'];
            $actualParams = array_map(fn($param) => $param->var->name, $node->params);

            if ($actualParams !== $expectedParams) {
                return ['Observer method signature should be (ObserverInterface $observer).'];
            }
        }

        return [];
    }

    private function isObserverMethod(Node\Stmt\ClassMethod $method): bool
    {
        return in_array($method->name->toString(), ['execute']);
    }
}
