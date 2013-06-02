using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace IV109
{
    class Program
    {
        static void Main(string[] args)
        {
            const string directory = "../plots/";
            const int ticks = 950;
            const int interval = 10;

            var output = new List<string>();

            var firstLine = "intersection,north,east,south,west";
            for (int i = 0; i <= ticks; i += interval)
                firstLine += "," + i;
            output.Add(firstLine);

            var runs = Directory.GetFiles(directory, "*.csv")
                            .Select(fileName => new Run(fileName))
                            .ToList(); //.Where(x => x.North == x.East && x.East == x.South && x.South == x.West);

            foreach (var run in runs)
            {
                output.Add(run.ToString(interval, ticks));
            }

            File.WriteAllLines("data.csv", output);
        }
    }
}