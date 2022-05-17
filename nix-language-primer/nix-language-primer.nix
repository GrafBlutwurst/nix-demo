#Let bindings is how you deal with "variables", of course, nix being purely functional they're actualy constants.
#The part after the "let" defines names that have valid nix expressions associated
#The part after the "in" is another nix expressions that can use those names 
#It's substitution all the way down

#you can run this file with 
# - `nix eval -f nix-language-primer.nix`
# - `nix eval --json -f nix-language-primer.nix | jq` because ofcourse nix can be rewritten as Json
# - `nix repl` you can then load the expression with `:l nix-language-primer.nix` and explore it in the repl

let
  #Primitives
  aString = "asdf";
  anInt = 14;
  aBoolean = true;

  #Paths are incredibly important in nix. But not to our purposes so we'll Ignore them. 
  #To fully understand why nix has a specific path type over just strings, I'd have to talk much more in-depth about how the derivation process (nix-expression -> something in nix-store) actually works  
  aPath = ./README.md;

  #Records are like json objects or dictionaries 
  aRecord = {
    a = 10;
    b = "foo";
  };

  #Lists don't have to homogenous (i.e. all elements of the same type, nix doesn't care)
  aList = [
    5
    "baz"
  ];

  #Functions in nix are allways fully curries. I.e. there are no functions that accept multiple arguments
  identityFunction = a: a;
  #So something like this in other languages would look e.g. like `x -> y -> x+y` 
  addFunction = x: y: x + y;
  #However if you don't like this way to deal with functions that need multiple inputs you can use records!
  #Feels a lot like multiple arguments but it isnt, we're just saying
  #  - Function with one argument 
  #  - That argument is a records 
  #  - And it must have 2 keys x,y
  #When you call this, you MUST provide a record with x and y, it's NOT positional. The names matter 
  addFunctionRecord = { x, y }: x + y;


in
# So here we now have the names from above available, we create a record with a bunch of fields that uses the above names
  # We'll look at a couple 
{
  #Does what you expect
  anInt = anInt;
  #However this can be abriviated, this does the same and is very common in nix usage.
  inherit aString;

  #Just a wrapper records to group some function call examples 
  functionCallBasics = {
    #Function application in nix is delimitted by space like in haskell. So it's not C-style identityFunction(4) 
    ident = identityFunction 4;

    #nix evaluates left associative, meaning if you want to nest function calls you'll have to use parenthesis 
    #This looks especially confusing to people that are used to C-style languages 
    ident2 = identityFunction (identityFunction 7);

    #Or you can use let bindings of course 
    ident3 =
      let
        intermediate = identityFunction 7;
      in
      identityFunction intermediate;
  };

  #Here we look at functions with multiple arguments as well as the rec keyword
  functionsWithMultipleArgs = rec {
    #This is how a currief function is called
    curried = addFunction 3 5;
    curriedSame = (addFunction 3) 5;

    #This does the exactly same thing. So what happens above is that the expressions (add 3) returns a function that is partially applied, we then apply 5 to that yielding the final result 
    curriedLet =
      let
        partiallyAppliedFunction = addFunction 3;
      in
      partiallyAppliedFunction 5;

    #And this is what calling a function with a record argument looks like. We call a function with one argument and that argumnent is a record. 
    recordFunctionCall = addFunctionRecord { x = 3; y = 5; };

    #This being a record the previous syntax of inherit works. 
    recordFunctionCallLet =
      let
        x = 3;
        y = 5;
      in
      addFunctionRecord {
        inherit x;
        inherit y;
      };

    #Normally nix wont let you refer to other keys defined in the same record because it can easily lead to infinite recursion (which nix will generally detect and yell at you for)
    #the "rec" keyword let's you enable this specifically 

    allTheSame = curried == curriedSame && curriedSame == curriedLet && curriedLet == recordFunctionCall && recordFunctionCall == recordFunctionCallLet;

  };

  #The "with" keyword allows you to abbriviate record navigation 
  #you'll see this a lot when we deal with nix packages which is a LARGE record 
  withExample =
    let
      aRecord = {
        a = 20;
        b = 30;
      };
    in
    with aRecord; a + b; #same as aRecord.a + aRecord.b so a bit like an import in other languages 

  #import is a function that is always available. It takes a path as an argument and its result is the nix expression the path points to 
  importExamples = {
    withALet =
      let
        mul = import ./somethingToImport.nix;
      in
      mul { x = 1; y = 1; };

    #Since this import points to a file that is a nix function we can also just call it 
    directly = import ./somethingToImport.nix { x = 1; y = 1; };
  };

  #nix also comes with a bunch of builtin functions see https://nixos.org/manual/nix/stable/expressions/builtins.html
  builtinExamples = with builtins; {
    #Check if 5 is in aList 
    contains = elem 5 aList;

    #Wait fetching stuff from git is a builtin ? oO 
    #Jup because that's how you actually get to packages in nix. Fetch source and build it 
    #Note it's guarded by a sha hash, protecting you from dependency hijacking and guaranteeing hash stability
    #The nix-prefetch-git command is your friend! nix-prefetch-git --url git@github.com:GrafBlutwurst/nix-demo.git 
    #You might wanna spin up a repl, load the expression and look at the result of this. We just put something into the nix store!
    gettingSourceCode = fetchGit {
      url = "git@github.com:GrafBlutwurst/nix-demo.git";
      rev = "81aed78888cc5e99e87fb19491cfc7f5d72a4583";
    };

    #Of course all the usual things you'd expect are here as well like a let 
    mapSomething =
      let
        aList = [ 1 2 3 ];
      in
      map
        (
          x: if x > 1 then x + 1 else x * 2
        )
        aList;
  };

  #Some more syntactical things you should be aware of 
  varia = {
    #records don't always have to be fully expanded you can use dot notation
    recordShorthand =
      let
        this = {
          a = {
            b = 1;
            c = 2;
          };
        };
        that = {
          a.b = 1;
          a.c = 2;
        };
      in
      this == that;

    #There's also dynamic key navigation
    dynamicKeys =
      let
        myKey = "foo";
        thing = {
          foo = 10;
        };
      in
      thing.${myKey};
  };

}
