using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace IV109
{
    class Program
    {
        private const string PlotsPath = "../../../plots/";
        private const string OutputPath = "../../../";
        private const int Ticks = 950;
        private const int Interval = 10;

        static void Main(string[] args)
        {
            var files = GetFiles().ToList();

            SaveToFile(files.Where(x => x.North == x.East && x.East == x.South && x.South == x.West),
                        "data-a.csv");

            SaveToFile(files.Where(x => x.North == x.South && x.East == x.West &&
                                             (x.North >= 20 && x.North < 60) &&
                                             (x.East >= 5 && x.East < 15)
                                        ),
                        "data-b.csv");

            SaveToFile(files.Where(x => x.North == x.East && x.West == x.South &&
                                             (x.North >= 20 && x.North < 60) &&
                                             (x.West >= 5 && x.West < 15)
                                        ),
                        "data-c.csv");


            var runs = new List<Run>();
            for (int i = 5; i < 15; i++)
            {
                runs.AddRange(files.Where(x => x.North == 4 * i && x.East == 3 * i && x.South == 2 * i && x.West == 1 * i));
            }
            runs = runs.OrderBy(x => x.Intersection)
                        .ThenBy(x => x.North)
                        .ThenBy(x => x.East)
                        .ThenBy(x => x.South)
                        .ThenBy(x => x.West)
                        .ToList();
            SaveToFile(runs, "data-d.csv");
        }

        private static IEnumerable<Run> GetFiles()
        {
            return Directory.GetFiles(PlotsPath, "*.csv")
                            .Select(fileName => new Run(fileName));
        }

        private static void SaveToFile(IEnumerable<Run> runs, string name)
        {
            var output = new List<string>();

            var firstLine = "intersection,run,north,east,south,west";
            for (int i = 0; i <= Ticks; i += Interval)
                firstLine += "," + i;
            output.Add(firstLine);

            int runNumber = 1;
            Run previousRun = null;
            foreach (var run in runs)
            {
                if (previousRun != null && previousRun.Intersection != run.Intersection)
                    runNumber = 1;
                output.Add(run.ToString(runNumber, Interval, Ticks));
                runNumber++;
                previousRun = run;
            }

            File.WriteAllLines(OutputPath + name, output);
        }
    }
}