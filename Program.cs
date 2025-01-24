using System.Diagnostics;

string path = Path.Combine(Path.GetTempPath(), "cpu-temp.txt");
PerformanceCounterCategory category = new("Thermal Zone Information");
PerformanceCounter counter = new(category.CategoryName, "Temperature", category.GetInstanceNames().First());

NotifyIcon notifyIcon = new();
ContextMenuStrip contextMenu = new();
ToolStripMenuItem quitMenuItem = new("Exit");

quitMenuItem.Click += (_, _) => Application.Exit();
contextMenu.Items.Add(quitMenuItem);

notifyIcon.Text = "Stream CPU Temperatures";
notifyIcon.Icon = SystemIcons.Information;
notifyIcon.ContextMenuStrip = contextMenu;
notifyIcon.Visible = true;

Application.ApplicationExit += (_, _) => notifyIcon.Dispose();

_ = Task.Run(async () =>
{
    while (true)
    {
        int temp = (int) counter.NextValue() - 273;
        await File.WriteAllTextAsync(path, temp.ToString());
        await Task.Delay(1000);
    }
    // ReSharper disable once FunctionNeverReturns
});

Application.Run();
