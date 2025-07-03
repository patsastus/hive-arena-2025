import std.stdio;
import map;

void main()
{
	auto map = loadMap("map.txt");
	foreach(pair; map.sortByCoords)
		writeln(pair[0], ":", pair[1]);

}
