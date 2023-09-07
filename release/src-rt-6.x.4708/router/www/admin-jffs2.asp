<!DOCTYPE html>
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html lang="en-GB">
<head>
<meta http-equiv="content-type" content="text/html;charset=utf-8">
<meta name="robots" content="noindex,nofollow">
<title>[<% ident(); %>] Admin: JFFS</title>
<link rel="stylesheet" type="text/css" href="tomato.css">
<% css(); %>
<script src="tomato.js"></script>

<script>

/* NVRAM2JFFS-BEGIN */
//	<% nvram("jffs2_on,jffs2_exec,t_fix1,nvram2jffs_enable,nvram2jffs_regex"); %>
/* NVRAM2JFFS-END */

/* NVRAM2JFFS-REMOVE-BEGIN */
//	<% nvram("jffs2_on,jffs2_exec,t_fix1"); %>
/* NVRAM2JFFS-REMOVE-END */

/* JFFS2-BEGIN */
//	<% statfs("/jffs", "jffs2"); %>
/* JFFS2-END */
/* JFFS2NAND-BEGIN */
//	<% statfs("/jffs", "brcmnand"); %>
/* JFFS2NAND-END */

fmtwait = (nvram.t_fix1 == 'RT-N16' ? 120 : 60);

function verifyFields(focused, quiet) {
	var b = !E('_f_jffs2_on').checked;
	E('format').disabled = b;
	E('_jffs2_exec').disabled = b;
/* NVRAM2JFFS-BEGIN */
	E('_f_nvram2jffs_enable').disabled = b;
	E('_nvram2jffs_regex').disabled = b;
/* NVRAM2JFFS-END */

	return 1;
}

function formatClicked() {
	if (!verifyFields(null, 0)) return;
	if (!confirm("Format the JFFS partition?")) return;
	save(1);
}

function formatClock() {
	if (ftime == 0) {
		E('fclock').innerHTML = 'a few more seconds';
	}
	else {
		E('fclock').innerHTML = ((ftime > 0) ? 'about ' : '') + ftime + ' second' + ((ftime == 1) ? '' : 's');
	}
	if (--ftime >= 0)
		setTimeout(formatClock, 1000);
}

function save(format) {
	if (!verifyFields(null, 0)) return;

	E('format').disabled = 1;
	if (format) {
		E('spin').style.display = 'inline-block';
		E('fmsg').style.display = 'inline-block';
	}

	var fom = E('t_fom');
	var on = E('_f_jffs2_on').checked ? 1 : 0;
	fom.jffs2_on.value = on;
	if (format) {
		fom.jffs2_format.value = 1;
		fom._commit.value = 0;
		fom._nextwait.value = fmtwait;
	}
	else {
		fom.jffs2_format.value = 0;
		fom._commit.value = 1;
		fom._nextwait.value = on ? 15 : 3;
	}
/* NVRAM2JFFS-BEGIN */
	fom.nvram2jffs_enable.value = E('_f_nvram2jffs_enable').checked ? 1 : 0;
/* NVRAM2JFFS-END */
	form.submit(fom, 1);

	if (format) {
		E('footer-msg').style.display = 'none';
		ftime = fmtwait;
		formatClock();
	}
}

function submit_complete() {
	reloadPage();
}
</script>
</head>

<body>
<form id="t_fom" method="post" action="tomato.cgi">
<table id="container">
<tr><td colspan="2" id="header">
	<div class="title">FreshTomato</div>
	<div class="version">Version <% version(); %> on <% nv("t_model_name"); %></div>
</td></tr>
<tr id="body"><td id="navi"><script>navi()</script></td>
<td id="content">
<div id="ident"><% ident(); %> | <script>wikiLink();</script></div>

<!-- / / / -->

<input type="hidden" name="_nextpage" value="admin-jffs2.asp">
<input type="hidden" name="_nextwait" value="10">
<input type="hidden" name="_service" value="jffs2-restart">
<input type="hidden" name="_commit" value="1">
<input type="hidden" name="jffs2_on">
/* NVRAM2JFFS-BEGIN */
<input type="hidden" name="nvram2jffs_enable">
/* NVRAM2JFFS-END */
<input type="hidden" name="jffs2_format" value="0">

<!-- / / / -->

<div class="section-title">JFFS</div>
<div class="section">
	<script>
		createFieldTable('', [
			{ title: 'Enable', name: 'f_jffs2_on', type: 'checkbox', value: (nvram.jffs2_on == 1) },
			{ title: 'Execute When Mounted', name: 'jffs2_exec', type: 'text', maxlen: 64, size: 34, value: nvram.jffs2_exec },
			null,
/* JFFS2-BEGIN */
			{ title: 'Total / Free Size', text: (((jffs2.mnt) || (jffs2.size > 0)) ? scaleSize(jffs2.size) : '') + ((jffs2.mnt) ? ' / ' + scaleSize(jffs2.free) : ' (not mounted)') },
/* JFFS2-END */
/* JFFS2NAND-BEGIN */
			{ title: 'Total / Free Size', text: (((brcmnand.mnt) || (brcmnand.size > 0)) ? scaleSize(brcmnand.size) : '') + ((brcmnand.mnt) ? ' / ' + scaleSize(brcmnand.free) : ' (not mounted)') },
/* JFFS2NAND-END */
			null,
			{ title: '', custom: '<input type="button" value="Format / Erase..." onclick="formatClicked()" id="format">' +
				'<img src="spin.gif" alt="" id="spin"> <span style="display:none" id="fmsg">Please wait for <span id="fclock">about 60 seconds<\/span>...<\/span>' }
		]);
	</script>
</div>

/* NVRAM2JFFS-BEGIN */
<div class="section-title">NVRAM2JFFS</div>
<div class="section">
	<script>
		createFieldTable('', [
			{ title: 'Enable nvram2jffs', name: 'f_nvram2jffs_enable', type: 'checkbox', value: (nvram.nvram2jffs_enable == 1) },
			{ title: 'Regex to match', name: 'nvram2jffs_regex', type: 'text', maxlen: 64, size: 34, value: nvram.nvram2jffs_regex },
		]);
	</script>
</div>
/* NVRAM2JFFS-END */

<!-- / / / -->

<script>show_notice1('<% notice("jffs"); %>');</script>

<!-- / / / -->

<div id="footer">
	<span id="footer-msg"></span>
	<input type="button" value="Save" id="save-button" onclick="save()">
	<input type="button" value="Cancel" id="cancel-button" onclick="reloadPage();">
</div>

</td></tr>
</table>
</form>
<script>verifyFields(null, true);</script>
</body>
</html>
