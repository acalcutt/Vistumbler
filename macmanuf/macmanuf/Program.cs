using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;

namespace macmanuf
{
    class Program
    {
        private static int FinishedDownloadFlag;

        static void Main(string[] args)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Script Name: Update Manufacturers");
            Console.WriteLine("By: Andrew Calcutt");
            Console.WriteLine("2016/02/05");
            Console.ForegroundColor = ConsoleColor.White;
            var cd = Directory.GetCurrentDirectory();
            var MDB = cd + "\\Manufacturers.mdb";
            File.Delete(MDB);
            Console.WriteLine(" - Creating MDB file '" + MDB + "'");
            CreateAccessDatabase(MDB);
            FinishedDownloadFlag = 0;
            var url = "http://standards.ieee.org/develop/regauth/oui/oui.txt";
            Console.WriteLine(" - Downloading Manufacturers from '" + url + "'");
            DownLoadFileInBackground(url);

            WaitForDownloadToFinish();

            Console.WriteLine(" - Parsing OUI.txt file and inserting into MDB.");
            GetManufacturers(MDB, url);
        }

        public static void WaitForDownloadToFinish()
        {
            while(FinishedDownloadFlag == 0){}
        }

        public static void CreateAccessDatabase(string file)
        {
            string connectionString = string.Format("Provider={0}; Data Source={1}; Jet OLEDB:Engine Type={2}",
                "Microsoft.Jet.OLEDB.4.0",
                file,
                5);

            ADOX.Catalog catalog = new ADOX.Catalog();
            catalog.Create(connectionString);

            ADOX.Table table = new ADOX.Table();
            table.Name = "Manufacturers";   // Table name

            // Column 1 (BSSID)
            ADOX.Column BSSIDCol = new ADOX.Column();
            BSSIDCol.Name = "BSSID";
            BSSIDCol.ParentCatalog = catalog;
            BSSIDCol.Type = ADOX.DataTypeEnum.adVarWChar;
            BSSIDCol.DefinedSize = 6;

            // Column 2 (Manufacturer)
            ADOX.Column ManuCol = new ADOX.Column();
            ManuCol.Name = "Manufacturer";
            ManuCol.ParentCatalog = catalog;
            ManuCol.Type = ADOX.DataTypeEnum.adVarWChar;
            ManuCol.DefinedSize = 255;

            table.Columns.Append(BSSIDCol);
            table.Columns.Append(ManuCol);
            catalog.Tables.Append(table);

            // Close the connection to the database after we are done creating it and adding the table to it.
            ADODB.Connection con = (ADODB.Connection)catalog.ActiveConnection;
            if (con != null && con.State != 0)
                con.Close();
        }

        public static void AddManu(string file, string BSSID, string Manufacturer)
        {
            string connectionString = string.Format("Provider={0}; Data Source={1}; Jet OLEDB:Engine Type={2}",
                "Microsoft.Jet.OLEDB.4.0",
                file,
                5);

            using (var con = new System.Data.OleDb.OleDbConnection(connectionString))
            {
                con.Open();     // Open a connection to the database.

                string query = "INSERT INTO Manufacturers ([BSSID],[Manufacturer]) VALUES (@BSSID,@Manufacturer);";

                using (var command = new System.Data.OleDb.OleDbCommand(query, con))
                {
                    command.Parameters.AddWithValue("@BSSID", BSSID);
                    command.Parameters.AddWithValue("@Manufacturer", Manufacturer);
                    command.ExecuteNonQuery();
                    System.Console.Write(" . ");
                }
            }
        }

        public static void GetManufacturers(string file, string url)
        {
            var client = new WebClient();
            
            using (var reader = new StreamReader("oui.txt"))
            {
                string line;
                while ((line = reader.ReadLine()) != null)
                {
                    if (line.Contains("(base 16)"))
                    {
                        string[] parts = line.Split(new string[] { "(base 16)" }, StringSplitOptions.None);
                        string bssidval = parts[0].Trim();
                        string manuval = parts[1].Trim();

                        AddManu(file, bssidval, manuval);
                        Console.WriteLine(bssidval + " " + manuval);
                    }
                }
            }
        }
        
        public static void DownLoadFileInBackground(string address)
        {
            WebClient client = new WebClient();
            Uri uri = new Uri(address);

            // Specify that the DownloadFileCallback method gets called
            // when the download completes.
            client.DownloadFileCompleted += new AsyncCompletedEventHandler(DownloadFileCompletedCallback);
            // Specify a progress notification handler.
            client.DownloadProgressChanged += new DownloadProgressChangedEventHandler(DownloadProgressCallback);
            client.DownloadFileAsync(uri, "oui.txt");
        }

        private static void UploadProgressCallback(object sender, UploadProgressChangedEventArgs e)
        {
            // Displays the operation identifier, and the transfer progress.
            Console.WriteLine("{0}    downloaded {1} of {2} bytes. {3} % complete...",
                (string)e.UserState,
                e.BytesSent,
                e.TotalBytesToSend,
                e.ProgressPercentage);
        }

        private static void DownloadProgressCallback(object sender, DownloadProgressChangedEventArgs e)
        {
            // Displays the operation identifier, and the transfer progress.
            Console.WriteLine("{0}    downloaded {1} of {2} bytes. {3} % complete...",
                (string)e.UserState,
                e.BytesReceived,
                e.TotalBytesToReceive,
                e.ProgressPercentage);
        }

        private static void DownloadFileCompletedCallback(object sender, AsyncCompletedEventArgs e)
        {
            // Displays the operation identifier, and the transfer progress.
            Console.WriteLine("Done!");
            FinishedDownloadFlag = 1;
        }

    }
}

