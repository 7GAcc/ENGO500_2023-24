function rpt = report_initializer(figurepath)
import mlreportgen.report.* 
import mlreportgen.dom.*
rpt = Report(figurepath,'pdf');
rpt.OutputPath = figurepath;

pageLayoutObj = PDFPageLayout;
pageLayoutObj.PageSize.Orientation = "landscape";
pageLayoutObj.PageSize.Height = "8.5in";
pageLayoutObj.PageSize.Width = "11in";

pageLayoutObj.PageMargins.Top = "0.3in";
pageLayoutObj.PageMargins.Bottom = "0.3in";
pageLayoutObj.PageMargins.Left = "0.3in";
pageLayoutObj.PageMargins.Right = "0.3in";

pageLayoutObj.PageMargins.Header = "0.3in";
pageLayoutObj.PageMargins.Footer = "0.3in";
add(rpt,pageLayoutObj);

end

