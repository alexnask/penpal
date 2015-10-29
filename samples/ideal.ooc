use penpal

main: func(argc: Int, argv: String[]) -> Int {
    path := argc > 1 ? argv[1] : "test.dwg"

    dwg := DWG new(path)
    if(dwg valid?()) {
        // This is just a handle, you can think of it as lazily evaluated list so nothing is pulled right here, unless we call 'exec'
        lines := dwg lines() filter~layer("TEST_LAYER YAY" as U16String) filter~color(Color ByLayer)
        // If we don't give a line constructing callback, we just get arrays of points
        lines callback(CBtype Line, |start, end| "Line with start #{start} and end #{end}" println(); null)

        // Here, we start pulling lines one by one with iterators
        for(line in lines) {
            // line is now null but stuff is printed from the callback :)
        }
    }
}
