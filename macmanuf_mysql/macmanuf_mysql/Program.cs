using System;
using System.Configuration;
using System.ComponentModel;
using System.IO;
using System.Net;
using MySql.Data.MySqlClient;


namespace macmanuf_mysql
{


    class Program
    {
        private static int FinishedDownloadFlag;

        static void Main(string[] args)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Script Name: Update Manufacturers MySQL");
            Console.WriteLine("By: Andrew Calcutt and Phil Ferland");
            Console.WriteLine("2018/09/10");
            Console.ForegroundColor = ConsoleColor.White;

            Console.WriteLine("Getting Connection ...");
            String connString = ConfigurationManager.ConnectionStrings["WifiDatabase"].ConnectionString;
            MySqlConnection conn = new MySqlConnection(connString);
            conn.Open();
            try
            {
                FinishedDownloadFlag = 0;
                string dt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
                var url = "http://standards-oui.ieee.org/oui/oui.txt";
                Console.WriteLine(" - Downloading Manufacturers from '" + url + "' for " + dt);
                DownLoadFileInBackground(url);

                WaitForDownloadToFinish();

                Console.WriteLine(" - Parsing OUI.txt file and inserting into MDB.");
                GetManufacturers(conn, url, dt);
            }
            catch (Exception e)
            {
                Console.WriteLine("Error: " + e);
                Console.WriteLine(e.StackTrace);
            }
            finally
            {
                // Close connection.
                conn.Close();
                // Dispose object, Freeing Resources.
                conn.Dispose();
            }
        }

        public static void WaitForDownloadToFinish()
        {
            while(FinishedDownloadFlag == 0){}
        }

        public static void AddManu(MySqlConnection conn, string BSSID, string Manufacturer, string dt)
        {

            MySqlCommand cmd = new MySqlCommand();
            try
            {

                cmd.Connection = conn;
                cmd.CommandText = "SELECT COUNT(*) FROM manufacturers WHERE BSSID=@BSSID";
                cmd.Prepare();
                cmd.Parameters.AddWithValue("@BSSID", BSSID);
                int rows = Convert.ToInt32(cmd.ExecuteScalar());

                MySqlCommand cmd2 = new MySqlCommand();
                try
                {
                    cmd2.Connection = conn;
                    if (rows > 0)
                    {
                        System.Console.Write("Updating-");
                        cmd2.CommandText = "UPDATE `manufacturers` SET `Manufacturer`=@Manufacturer, `modified`=@modified WHERE BSSID=@BSSID;";
                    }
                    else
                    {
                        System.Console.Write("Inserting-");
                        cmd2.CommandText = "INSERT INTO `manufacturers` (`BSSID`,`Manufacturer`,`modified`) VALUES(@BSSID,@Manufacturer,@modified);";
                    }
                    cmd2.Prepare();
                    cmd2.Parameters.AddWithValue("@BSSID", BSSID);
                    cmd2.Parameters.AddWithValue("@Manufacturer", Manufacturer);
                    cmd2.Parameters.AddWithValue("@modified", dt);
                    cmd2.ExecuteNonQuery();
                }
                catch (MySql.Data.MySqlClient.MySqlException ex)
                {
                    System.Console.Write("Error " + ex.Number + " has occurred: " + ex.Message);
                }
            }
            catch (MySql.Data.MySqlClient.MySqlException ex)
            {
                System.Console.Write("Error " + ex.Number + " has occurred: " + ex.Message);
            }
        }

        public static void GetManufacturers(MySqlConnection conn, string url, string dt)
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

                        AddManu(conn, bssidval, manuval, dt);
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
            Console.WriteLine("{0}    downloaded {1}",
                (string)e.UserState,
                e.BytesSent);
        }

        private static void DownloadProgressCallback(object sender, DownloadProgressChangedEventArgs e)
        {
            // Displays the operation identifier, and the transfer progress.
            Console.WriteLine("{0}    downloaded {1}",
                (string)e.UserState,
                e.BytesReceived);
        }

        private static void DownloadFileCompletedCallback(object sender, AsyncCompletedEventArgs e)
        {
            // Displays the operation identifier, and the transfer progress.
            Console.WriteLine("Done!");
            FinishedDownloadFlag = 1;
        }

    }
}

