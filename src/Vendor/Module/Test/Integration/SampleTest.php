<?php

declare(strict_types=1);

namespace Vendor\Module\Test\Integration;

class SampleTest extends \PHPUnit\Framework\TestCase
{
    public function testSampleMethod(): void
    {
        $this->assertEquals(10, 5 + 5);
    }
}
