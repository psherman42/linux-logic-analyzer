# linux-logic-analyzer
Easy to use CLI based digital signal logic analyzer
```
./sense.sh --c1 <gpio-num> --c2 <gpio-num> --c3 <gpio-num>\
           --tc <gpio-num> --tp <+ | -> --tm <norm | auto>\
           --cl1 <label> -cl2 <label> -cl3 <label>
```
**c1, c2, c3** are channel GPIO pin(s), not the physical pins

**tc** is the trigger channel GPIO pin

**tp** is the trigger polarity (+ or -)

**tm** is the trigger mode (auto or norm)

**cl1, cl2, cl3** are channel label(s), 8 char. max, please.


Supports up to three GPIO channels, for now.
Use an elevated command prompt ... or 'sudo' for best results.

![LinuxLogicAnalyzer](https://user-images.githubusercontent.com/36460742/184530503-dff819aa-8683-4606-90f7-7425a1cf5a06.jpg)
