# ==============================================================================
# PPM to PNG Converter Utility
# ==============================================================================
param(
    [Parameter(Mandatory=$true)]
    [string]$InputPpm,
    [Parameter(Mandatory=$true)]
    [string]$OutputPng
)

$csharpCode = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

public class PpmConverter {
    public static void PpmToPng(string ppmPath, string pngPath) {
        using (var fs = new FileStream(ppmPath, FileMode.Open, FileAccess.Read)) {
            using (var reader = new BinaryReader(fs)) {
                string magic = ReadToken(reader);
                if (magic != "P6") throw new Exception("Not a binary P6 PPM");
                int width = int.Parse(ReadToken(reader));
                int height = int.Parse(ReadToken(reader));
                int maxVal = int.Parse(ReadToken(reader));
                
                var bmp = new Bitmap(width, height, PixelFormat.Format24bppRgb);
                var bmpData = bmp.LockBits(new Rectangle(0, 0, width, height), ImageLockMode.WriteOnly, PixelFormat.Format24bppRgb);
                int stride = bmpData.Stride;
                IntPtr ptr = bmpData.Scan0;
                int totalBytes = stride * height;
                byte[] rgbValues = new byte[totalBytes];
                
                for (int y = 0; y < height; y++) {
                    for (int x = 0; x < width; x++) {
                        byte r = reader.ReadByte();
                        byte g = reader.ReadByte();
                        byte b = reader.ReadByte();
                        int idx = y * stride + x * 3;
                        rgbValues[idx] = b;
                        rgbValues[idx + 1] = g;
                        rgbValues[idx + 2] = r;
                    }
                }
                System.Runtime.InteropServices.Marshal.Copy(rgbValues, 0, ptr, totalBytes);
                bmp.UnlockBits(bmpData);
                bmp.Save(pngPath, ImageFormat.Png);
            }
        }
    }
    private static string ReadToken(BinaryReader reader) {
        var sb = new System.Text.StringBuilder();
        int b;
        while ((b = reader.Read()) != -1) {
            char c = (char)b;
            if (c == '#') { while ((b = reader.Read()) != -1 && b != '\n'); continue; }
            if (!char.IsWhiteSpace(c)) { sb.Append(c); break; }
        }
        while ((b = reader.Read()) != -1) {
            char c = (char)b;
            if (char.IsWhiteSpace(c)) break;
            sb.Append(c);
        }
        return sb.ToString();
    }
}
"@

if (-not ([System.Management.Automation.PSTypeName]'PpmConverter').Type) {
    Add-Type -TypeDefinition $csharpCode -ReferencedAssemblies System.Drawing
}

[PpmConverter]::PpmToPng((Resolve-Path $InputPpm).Path, $OutputPng)
Write-Host "Converted $InputPpm -> $OutputPng"
