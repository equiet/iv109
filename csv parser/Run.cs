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
            var lines = File.ReadAllLines(FilePath).Skip(17);

            string output = string.Format("{0},{1},{2},{3},{4},{5}", Intersection, runNumber, North, East, South, West);
            foreach (var line in lines)
            {
                int x; float y;
                ParseLine(line, out x, out y);
                if (x % interval == 0 && x <= maxTicks)
                {
                    output += "," + y.ToString().Replace(",", ".");
                }
            }

            return output;
        }

        public override string ToString()
        {
            return ToString(1, 10, 200);
        }

        private void ParseLine(string line, out int x, out float y)
        {
            var arr = line.Split(',').ToList();
            for (int i = 0; i < arr.Count; i++)
                arr[i] = arr[i].Replace("\"", "");
            x = int.Parse(arr[0]);
            y = float.Parse(arr[1].Replace(".", ","));
        }
    }
}