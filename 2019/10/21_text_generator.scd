/*

Date: 21/10/2019.

Goal was to output a text containing N words based on any input text.

*/

~text="Try this out and then leave the server running. Many examples in the documentation have s.boot at the beginning, but in general you should make sure the server is running before using any examples that generate audio, or otherwise access the server. In general the examples in this tutorial assume that the server is running.";

// cans also read from a file
//~text = File.readAllString("/path/to/text.txt")
~words = ~text.split(Char.space);

(
~generate = { arg target;
	~position = 0;
	~possibles = [];
	while({~words.find ([target], ~position) != nil; }, {
		~position = ~words.find ([target], ~position);
		~position = ~position + 1;
		if(~words[~position] != nil , {
			~possibles=~possibles.add(~words[~position]);
		});
	});
	~possibles.choose
};

~autoText = {arg target, times;
	var result = "";
	times.do {
		target = ~generate.value(target);
		result = result + target;
	};
	result;
}
);

~autoText.value("the", 100);
