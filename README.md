## Penpal

Penpal is a native ooc library meant to be used to write fast automation code for AutoCAD DWG files.

### Why?

I recently was trying to automate a seemingly trivial task in AutoLISP, only to find out it is horribly slow and tedious to do so.
I circumvented the problem by writing exporting and importing code in AutoLISP and doing the majority of the work in Python, which turned out to work decently well.

### How?

Right now I am planning on reading the DWG files directly in ooc code and letting YOU, the user, use your favorite geometry library that fits your needs by hooking calls that return objects of your choice.
However, editing the drawings directly would be pretty suicidal, so I am considering using some kind of bridge to AutoCAD to do this stuff.

### Example

Here is a trivial example that demonstrates how I want code to look like

```ooc
use penpal

main: func(argc: Int, argv: CString[]) -> Int {
    path := argc > 1 ? argv[1] : "test.dwg"

    dwg := DWG new(path)
    if(dwg valid?()) {
        // This is just a handle, you can think of it as lazily evaluated list so nothing is pulled right here, unless we call 'exec'
        lines := dwg getLines() filter~layer("TEST_LAYER YAY" as U16String) filter~color(Color ByLayer)
        // If we don't give a line constructing callback, we just get arrays of points
        lines callback(CBtype Line, |start, end| "Line with start #{start} and end #{end}" println(); null)

        // Here, we start pulling lines one by one with iterators
        for(line in lines) {
            // line is now null but stuff is printed from the callback :)
        }
    }
}

```

### Authors

  * Alexandros Naskos <alex@naskos.email>