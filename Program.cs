using System.Diagnostics;

string path = Path.Combine(Path.GetTempPath(), "cpu-temp.txt");
PerformanceCounterCategory category = new("Thermal Zone Information");
PerformanceCounter counter = new(category.CategoryName, "Temperature", category.GetInstanceNames().First());

while (true)
{
    int temp = (int) counter.NextValue() - 273;
    await File.WriteAllTextAsync(path, temp.ToString());
    await Task.Delay(1000);
}
