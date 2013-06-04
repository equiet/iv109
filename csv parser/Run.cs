using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace IV109
{
    class Run
    {
        public Run(string path)
        {
            FilePath = path;

            var variables = Path.GetFileNameWithoutExtension(path).Split('_');
            Intersection = variables[0];
            North = int.Parse(variables[1]);
            East = int.Parse(variables[2]);
            South = int.Parse(variables[3]);
            West = int.Parse(variables[4]);
        }

        public string FilePath { get; set; }
        public string Intersection { get; set; }
        public int North { get; set; }
        public int East { get; set; }
        public int South { get; set; }
        public int West { get; set; }

        public string ToString(int runNumber, int interval, int maxTicks)
        {
            var lines = File.ReadAllLines(FilePath).Skip(21);

            string total = Intersection;
            string north = Intersection + "-north";
            string east = total + "-east";
            string south = total + "-south";
            string west = total + "-west";
            total += string.Format(",{0},{1},{2},{3},{4}", runNumber, North, East, South,West);
            north += string.Format(",{0},{1},{2},{3},{4}", runNumber, North, East, South, West);
            east += string.Format(",{0},{1},{2},{3},{4}", runNumber, North, East, South, West);
            south += string.Format(",{0},{1},{2},{3},{4}", runNumber, North, East, South, West);
            west += string.Format(",{0},{1},{2},{3},{4}", runNumber, North, East, South, West);

            foreach (var line in lines)
            {
                var arr = ParseLine(line);
                int x = int.Parse(arr[0]);
                float y = float.Parse(arr[1].Replace(".", ","));
                if (x % interval == 0 && x <= maxTicks)
                {
                    total += "," + y.ToString().Replace(",", ".");
                    north += "," + GetY(arr[5]);
                    east += "," + GetY(arr[9]);
                    south += "," + GetY(arr[13]);
                    west += "," + GetY(arr[17]);
                }
            }

            return string.Format("{0}\\n{1}\\n{2}\\n{3}\\n{4}", total, north, east, south, west);
        }

        private string GetY(string v)
        {
            return float.Parse(v.Replace(".", ",")).ToString().Replace(",", ".");
        }

        public override string ToString()
        {
            return ToString(1, 10, 200);
        }

        private List<string> ParseLine(string line)
        {
            var arr = line.Split(',').ToList();
            for (int i = 0; i < arr.Count; i++)
                arr[i] = arr[i].Replace("\"", "");
            return arr;
        }
    }
}