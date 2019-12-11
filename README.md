## Opal Multishake Demo

Based on a basic implementation by @jgaskins and discussion here: https://github.com/opal/opal/issues/1734

This is an experimental demo. It aims to reduce a very basic Opal script to the barebones. It may provide some
food for thought for the idea of reducing unused code for Opal 1.2. The code quality may not be too high, consider
it as my code golf or a playground at this point (but I use it to minify some of my "production" code and well -
I can't say it doesn't work).

Weaknesses:
- Bridged classes may be removed. If your code involves bridged classes, you may want to add a reference in your
  code if some class you use gets removed. Bridged classes mean classes defined this way:
  ```class Promise < `Promise` ```.
- This involves very basic regular expressions and it contains no syntax parsing whatsoever. This means, that you
  need to be especially careful when compressing code that may involve dangling ('s or {'s even if escaped inside
  a string. I crashed my computer while compiling opal-parser.

Strengths:
- For certain, carefully crafted code, it can give you even 50% or more size reduction. This obviously means load
  speedup.

Multishake involves 3 scripts:
- tree_shake - removing unused methods (using the stub subsystem)
- const_shake - removing unused constants, classes, modules
- runtime_shake - removing unused functions declared as "function x" or "Opal.x = function"
- ...and additionally it removes the stub subsystem

# Usage

I made no effort for it to be usable outside the Unix world. Check out the `Rakefile`, you will need
node, google-closure-compiler and brotli. Those are not hard requirements, but we use them for benchmarking purposes.
For google-closure-compiler, try this: `npm install -g google-closure-compiler`

```
$ bundle
$ rake
```

# How well does it work exactly?

For the most basic Hello world script (with opal/base, opal/mini, opal and opal+opal-browser included respectively):

Loading times:

    Success: dist/opal_base.js (0.156614396s)
    Success: dist/opal_base.min.js (0.120598327s)
    Success: dist/opal_base.shake.js (0.111505545s)
    Success: dist/opal_base.shake.min.js (0.10618925s)
    Success: dist/opal_mini.js (0.184016251s)
    Success: dist/opal_mini.min.js (0.170962531s)
    Success: dist/opal_mini.shake.js (0.14563446s)
    Success: dist/opal_mini.shake.min.js (0.144404704s)
    Success: dist/opal_std.js (0.222841628s)
    Success: dist/opal_std.min.js (0.200817291s)
    Success: dist/opal_std.shake.js (0.176391307s)
    Success: dist/opal_std.shake.min.js (0.163372925s)
    Success: dist/opal_x_browser.js (0.434136712s)
    Success: dist/opal_x_browser.min.js (0.394412487s)
    Success: dist/opal_x_browser.shake.js (0.300694974s)
    Success: dist/opal_x_browser.shake.min.js (0.287267739s)

Sizes:

    dist/opal_base.js: 181898 -> 102275 (43.77% reduction)
    dist/opal_base.min.js: 70638 -> 35034 (50.4% reduction)
    dist/opal_base.min.js.gz: 19073 -> 10391 (45.52% reduction)
    dist/opal_base.min.js.br: 17114 -> 9403 (45.06% reduction)
    dist/opal_mini.js: 587800 -> 297909 (49.32% reduction)
    dist/opal_mini.min.js: 232993 -> 110502 (52.57% reduction)
    dist/opal_mini.min.js.gz: 58405 -> 29428 (49.61% reduction)
    dist/opal_mini.min.js.br: 49070 -> 25628 (47.77% reduction)
    dist/opal_std.js: 771395 -> 463109 (39.96% reduction)
    dist/opal_std.min.js: 313154 -> 178336 (43.05% reduction)
    dist/opal_std.min.js.gz: 78754 -> 46926 (40.41% reduction)
    dist/opal_std.min.js.br: 65021 -> 39668 (38.99% reduction)
    dist/opal_x_browser.js: 1365725 -> 929422 (31.95% reduction)
    dist/opal_x_browser.min.js: 564557 -> 366205 (35.13% reduction)
    dist/opal_x_browser.min.js.gz: 129060 -> 85511 (33.74% reduction)
    dist/opal_x_browser.min.js.br: 104366 -> 69974 (32.95% reduction)

(Please update this part if you will happen to make some improvements)
