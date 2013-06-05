using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IV109_XML_generator
{
    class Program
    {
        static void Main(string[] args)
        {
            int experimentId = 1;
            var output = new List<string>();
            output.Add(@"<?xml version=""1.0"" encoding=""us-ascii""?><!DOCTYPE experiments SYSTEM ""behaviorspace.dtd""><experiments>");


            for (int i = 10; i <= 60; i += 2)
            {
                output.Add(GetExperiment(experimentId, i, i, i, i));
                experimentId++;
            }

            for (int i = 5; i < 15; i++)
            {
                output.Add(GetExperiment(experimentId, 4 * i, 1 * i, 4 * i, 1 * i));
                experimentId++;
            }

            for (int i = 5; i < 15; i++)
            {
                output.Add(GetExperiment(experimentId, 4 * i, 4 * i, 1 * i, 1 * i));
                experimentId++;
            }

            for (int i = 5; i < 15; i++)
            {
                output.Add(GetExperiment(experimentId, 4 * i, 3 * i, 2 * i, 1 * i));
                experimentId++;
            }

            output.Add("</experiments>");
            File.WriteAllLines(@"C:\Users\Santas\Documents\GitHub\iv109\experiments-setup.xml", output);
        }

        static string GetExperiment(int experimentId, int north, int east, int south, int west)
        {
            return @"<experiment name=""experiment" + experimentId + @""" repetitions=""1"" runMetricsEveryStep=""true"">
<setup>startup</setup>
<go>go</go>
<final>export</final>
<timeLimit steps=""2000""/>
<enumeratedValueSet variable=""intersection"">
    <value value=""&quot;roundabout&quot;""/>
    <value value=""&quot;roundabout-quick-right&quot;""/>
    <value value=""&quot;traffic-lights&quot;""/>
</enumeratedValueSet>
<enumeratedValueSet variable=""north-frequency"">
    <value value=""" + north + @"""/>
</enumeratedValueSet>
<enumeratedValueSet variable=""east-frequency"">
    <value value=""" + east + @"""/>
</enumeratedValueSet>
<enumeratedValueSet variable=""south-frequency"">
    <value value=""" + south + @"""/>
</enumeratedValueSet>
<enumeratedValueSet variable=""west-frequency"">
    <value value=""" + west + @"""/>
</enumeratedValueSet>
</experiment>";
        }
    }
}
