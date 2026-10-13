<# :
@echo off
REM ===========================================================================
REM Instalador do V9 Flow (Windows 10/11). Dois cliques e seguir a tela.
REM A parte de cima e' so' a casca: o instalador de verdade e' o PowerShell
REM que vem abaixo, neste mesmo arquivo. Rodar de novo = atualizar/consertar.
REM ===========================================================================
setlocal
title Instalador do V9 Flow
set "INSTALADOR=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ([IO.File]::ReadAllText($env:INSTALADOR))"
echo.
pause
exit /b
#>

# ============================ CONFIGURACAO ================================
# Onde o pacote cifrado do app e a lista de membros ficam publicados (repositorio
# publico: so' tem arquivo cifrado, o codigo nao e' legivel sem login e senha).
# E' um repositorio SEPARADO do V9 Vision: atualizar um nao mexe no outro.
$Dist    = 'Hardyrx/v9flow-dist'
$Destino = 'C:\V9Flow'        # so' o padrao: a pessoa escolhe a unidade ao instalar
# Auxiliar de criptografia (instalador\v9flow_cofre.py), embutido em base64.
$CofrePyB64 = 'IyEvdXNyL2Jpbi9lbnYgcHl0aG9uMw0KIiIiDQpWOSBGTE9XIC8vIGNvZnJlIGRvIGluc3RhbGFkb3IgZSBkYSBwdWJsaWNhY2FvLg0KDQpNZXNtbyBlc3F1ZW1hIGRvIFY5IFZpc2lvbiAoYXBwLXZpZGVvcy9pbnN0YWxhZG9yL3Y5X2NvZnJlLnB5KTogYSBsaXN0YSBkZSBtZW1icm9zIChtZW1icm9zLmpzb24sIGZvcm1hdG8gMiBkbw0KVjkgT3JhY2xlKSBndWFyZGEsIHBhcmEgY2FkYSBsb2dpbiwgYSBjaGF2ZSBkZSBkYWRvcyB0cmFuY2FkYSBjb20gYSBzZW5oYSBkZWxlLiBVbSBsb2dpbiB2YWxpZG8gYWJyZSBhIGNoYXZlIGRlIGRhZG9zOw0KYSBjaGF2ZSBkZSBkYWRvcyBhYnJlIG8gcGFjb3RlIGRvIGFwcCAoZm9ybWF0byBWOUUxOiBub25jZSArIEFFUy0yNTYtR0NNIHNvYnJlIGd6aXAgZGUgdW0gemlwKS4NCg0KRGlmZXJlbmNhIHBhcmEgbyBWOSBWaXNpb246IG8gcGFjb3RlIGUnIG1vbnRhZG8gYSBwYXJ0aXIgZGEgUEFTVEEsIGNvbSB1bWEgbGlzdGEgZG8gcXVlIGZpY2EgZm9yYSAodmVudiwgcmVtb3Rpb24sDQpmZXJyYW1lbnRhcyBkZSB0ZXN0ZSwgYW5hbGlzZXMsIGRhZG9zIGxvY2FpcywgbyBwcm9wcmlvIGluc3RhbGFkb3IpLg0KDQpTTycgUVVFTSBDT01QUk9VICgyMDI2LTEwLTEyKTogbyBWOSBGbG93IHRlbSBjaGF2ZSBkZSBkYWRvcyBQUk9QUklBIGUgbGlzdGEgUFJPUFJJQSAoYSBtZW1icm9zLmpzb24gZG8gdjlmbG93LWRpc3QpLg0KQSBsaXN0YSBkbyBGbG93IGUnIG1vbnRhZGEgYSBwYXJ0aXIgZGEgbGlzdGEgZG8gT3JhY2xlLCBzbycgY29tIG9zIGNvbXByYWRvcmVzIGVzY29saGlkb3MgcGVsbyBhZG1pbmlzdHJhZG9yOiBjYWRhIHVtDQpyZWNlYmUgYSBjaGF2ZSBkbyBGbG93IG5hIGNoYXZlIFBVQkxJQ0EgZGVsZSAoc2VtIHByZWNpc2FyIGRhIHNlbmhhKSBlIGNvbnRpbnVhIGVudHJhbmRvIGNvbSBvIG1lc21vIGxvZ2luIGUgc2VuaGEuDQpBIGNoYXZlIGRvIE9yYWNsZS9WOSBWaXNpb24gbmFvIGFicmUgbyBwYWNvdGUgZG8gRmxvdywgZSBxdWVtIG5hbyBlc3RhIG5hIGxpc3RhIGRvIEZsb3cgbmFvIGluc3RhbGEuDQoNCkNvbWFuZG9zOg0KICBhYnJpciAgICAgLS1tZW1icm9zIEFSUSAgICAgICAgICAgICAgICAgICAgIHN0ZGluOiBsb2dpbiwgc2VuaGEgKGR1YXMgbGluaGFzKSAgLT4gc3Rkb3V0OiBjaGF2ZSAoYmFzZTY0KQ0KICBkZWNpZnJhciAgLS1wYWNvdGUgQVJRIC0tZGVzdGlubyBQQVNUQSAgICAgIHN0ZGluOiBjaGF2ZSAoYmFzZTY0KSAgICAgICAgICAgICAgIC0+IGV4dHJhaSBvIGFwcA0KICBndWFyZGFyICAgLS1kZXN0aW5vIEFSUSAgICAgICAgICAgICAgICAgICAgIHN0ZGluOiBjaGF2ZSAoYmFzZTY0KSAtPiBncmF2YSBwcm90ZWdpZGEgcGVsbyBXaW5kb3dzIChEUEFQSSkNCiAgY29tcHJhZG9yZXMgLS1vcmFjbGUgQVJRIC0tZmxvdyBBUlEgWy0tZXNjb2xoYSAiMSwzLDUiIHwgLS1lc2NvbGhhID1dIFstLXRyb2Nhci1jaGF2ZV0NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzdGRpbjogbG9naW4sIHNlbmhhIGRvIGFkbWluaXN0cmFkb3IuIFNlbSAtLWVzY29saGE6IHNvJyBtb3N0cmEgYQ0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGxpc3RhIG51bWVyYWRhIChbeF0gPSBqYSB0ZW0gbyBGbG93KS4gQ29tIC0tZXNjb2xoYTogZ3JhdmEgYSBsaXN0YSBkbw0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIEZsb3cgKG8gYWRtaW5pc3RyYWRvciBlbnRyYSBzZW1wcmU7ICI9IiBtYW50ZW0gcXVlbSBqYSBlc3RhKS4NCiAgcHVibGljYXIgIC0tYXBwIFBBU1RBIC0tZGlzdCBQQVNUQSAtLW1lbWJyb3MgQVJRIFstLXZlcnNhbyBWXQ0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHN0ZGluOiBsb2dpbiwgc2VuaGEgZG8gYWRtaW5pc3RyYWRvci4gLS1tZW1icm9zID0gYSBsaXN0YSBkbyBGTE9XLg0KICBsaXN0YXIgICAgLS1hcHAgUEFTVEEgICAgICAgICAgICAgICAgICAgICAgIG1vc3RyYSBvIHF1ZSBlbnRyYXJpYSBubyBwYWNvdGUgKG5hbyBwcmVjaXNhIGRlIGxvZ2luKQ0KQ29kaWdvcyBkZSBzYWlkYTogMCBvaywgMiBsb2dpbiBvdSBzZW5oYSBpbmNvcnJldG9zLCAzIGFycXVpdm8gYXVzZW50ZSBvdSBpbnZhbGlkbywgNCBwYWNvdGUgbmFvIGFicmUsDQogICAgICAgICAgICAgICAgICA2IHZlcnNhbyBpZ3VhbCBhIGphIHB1YmxpY2FkYS4NCiIiIg0KaW1wb3J0IGFyZ3BhcnNlLCBiYXNlNjQsIGN0eXBlcywgZm5tYXRjaCwgZ3ppcCwgaGFzaGxpYiwgaW8sIGpzb24sIG9zLCByZSwgc3lzLCB0aW1lLCB6aXBmaWxlDQoNCmZyb20gY3J5cHRvZ3JhcGh5LmV4Y2VwdGlvbnMgaW1wb3J0IEludmFsaWRUYWcNCmZyb20gY3J5cHRvZ3JhcGh5Lmhhem1hdC5wcmltaXRpdmVzIGltcG9ydCBoYXNoZXMNCmZyb20gY3J5cHRvZ3JhcGh5Lmhhem1hdC5wcmltaXRpdmVzLmFzeW1tZXRyaWMueDI1NTE5IGltcG9ydCBYMjU1MTlQcml2YXRlS2V5LCBYMjU1MTlQdWJsaWNLZXkNCmZyb20gY3J5cHRvZ3JhcGh5Lmhhem1hdC5wcmltaXRpdmVzLnNlcmlhbGl6YXRpb24gaW1wb3J0IEVuY29kaW5nLCBQdWJsaWNGb3JtYXQNCmZyb20gY3J5cHRvZ3JhcGh5Lmhhem1hdC5wcmltaXRpdmVzLmNpcGhlcnMuYWVhZCBpbXBvcnQgQUVTR0NNDQpmcm9tIGNyeXB0b2dyYXBoeS5oYXptYXQucHJpbWl0aXZlcy5rZGYuaGtkZiBpbXBvcnQgSEtERg0KDQp0cnk6DQogICAgc3lzLnN0ZGluLnJlY29uZmlndXJlKGVuY29kaW5nPSJ1dGYtOC1zaWciLCBlcnJvcnM9InN0cmljdCIpICAgIyBvIFBvd2VyU2hlbGwgbWFuZGEgVVRGLTgsIGFzIHZlemVzIGNvbSBCT00gaW52aXNpdmVsDQogICAgc3lzLnN0ZG91dC5yZWNvbmZpZ3VyZShlbmNvZGluZz0idXRmLTgiLCBlcnJvcnM9InJlcGxhY2UiKQ0KICAgIHN5cy5zdGRlcnIucmVjb25maWd1cmUoZW5jb2Rpbmc9InV0Zi04IiwgZXJyb3JzPSJyZXBsYWNlIikNCmV4Y2VwdCBFeGNlcHRpb246DQogICAgcGFzcw0KDQpNQUdJQyA9IGIiVjlFMSINCklURVIgPSA2MDBfMDAwDQpBUlFVSVZPX1BBQ09URSA9ICJhcHAudjlwa2ciDQoNCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSBvIHF1ZSBOQU8gdmFpIHBhcmEgbyBtZW1icm8NCiMgUGFzdGFzIChlbSBxdWFscXVlciBuaXZlbCk6IGxpeG8gZGUgUHl0aG9uL2dpdC9ub2RlLg0KRk9SQV9QQVNUQVNfVE9EQVMgPSB7Il9fcHljYWNoZV9fIiwgIi5naXQiLCAibm9kZV9tb2R1bGVzIiwgIi5weXRlc3RfY2FjaGUiLCAiLmNhY2hlIn0NCiMgUGFzdGFzIGRhIHJhaXo6IGFtYmllbnRlIGxvY2FsLCBmZXJyYW1lbnRhcyBkZSB0ZXN0ZSwgUmVtb3Rpb24gKHNvJyBhcyBmZXJyYW1lbnRhcyB1c2FtKSwgbyBwcm9wcmlvIGluc3RhbGFkb3IuDQpGT1JBX1BBU1RBU19SQUlaID0geyJ2ZW52IiwgInJlbW90aW9uIiwgImZlcnJhbWVudGFzIiwgInRlc3RlcyIsICJpbnN0YWxhZG9yIiwgImxvZ3MiLCAiZGlzdCJ9DQojIEFycXVpdm9zIChlbSBxdWFscXVlciBuaXZlbCwgcG9yIHBhZHJhbyBkZSBub21lKTogZGFkb3MgbG9jYWlzIGUgbGl4by4NCkZPUkFfQVJRVUlWT1MgPSBbImNvbmZpZy5qc29uIiwgIioucHljIiwgIioubG9nIiwgIioudG1wIiwgIioubG9jayIsICJwb3J0YV9hdGl2YS50eHQiLCAiZmlsYS5qc29uIiwgIlRodW1icy5kYiIsDQogICAgICAgICAgICAgICAgICJkZXNrdG9wLmluaSJdDQojIEFycXVpdm9zIGRhIHJhaXo6IGNvaXNhIGRlIHF1ZW0gZGVzZW52b2x2ZSBlIG1hcmNhcyBkZSB1bWEgaW5zdGFsYWNhby4NCkZPUkFfQVJRVUlWT1NfUkFJWiA9IFsiQU5BTElTRS0qLm1kIiwgIklOU1RBTEFSLmJhdCIsICJQVUJMSUNBUi0qLmJhdCIsICJpbnN0YWxhZG9fcGFyYS50eHQiLCAiZGlzdF91cmwudHh0IiwNCiAgICAgICAgICAgICAgICAgICAgICAidGVybW9fYWNlaXRvLnR4dCJdDQojIFNlbSBlc3RlcyBvIHBhY290ZSBuYW8gZScgdW0gVjkgRmxvdyBxdWUgYWJyZSBlIHNlIGF0dWFsaXphLg0KT0JSSUdBVE9SSU9TID0gWyJWRVJTQU8iLCAicmVxdWlyZW1lbnRzLnR4dCIsICJhYnJpci5weXciLCAiYXR1YWxpemFkb3IucHkiLCAidjlmbG93L19fbWFpbl9fLnB5IiwgImV4dGVuc2FvL21hbmlmZXN0Lmpzb24iLA0KICAgICAgICAgICAgICAgICJsaWNlbmNhX3B1YmxpY2EuanNvbiIsICJ2OWZsb3cvbGljZW5jYS5weSJdDQoNCg0KZGVmIGFycXVpdm9zX2RvX3BhY290ZShhcHApOg0KICAgICIiIkxpc3RhIChjYW1pbmhvIG5vIGRpc2NvLCBub21lIG5vIHppcCkgZG8gcXVlIHZhaSBubyBwYWNvdGUsIGVtIG9yZGVtLiIiIg0KICAgIGFwcCA9IG9zLnBhdGguYWJzcGF0aChhcHApDQogICAgaXRlbnMgPSBbXQ0KICAgIGZvciByYWl6LCBwYXN0YXMsIGFycXMgaW4gb3Mud2FsayhhcHApOg0KICAgICAgICByZWwgPSBvcy5wYXRoLnJlbHBhdGgocmFpeiwgYXBwKQ0KICAgICAgICBuYV9yYWl6ID0gcmVsID09ICIuIg0KICAgICAgICBwYXN0YXNbOl0gPSBzb3J0ZWQocCBmb3IgcCBpbiBwYXN0YXMNCiAgICAgICAgICAgICAgICAgICAgICAgICAgIGlmIHAgbm90IGluIEZPUkFfUEFTVEFTX1RPREFTIGFuZCBub3QgKG5hX3JhaXogYW5kIHAgaW4gRk9SQV9QQVNUQVNfUkFJWikpDQogICAgICAgIGZvciBub21lIGluIHNvcnRlZChhcnFzKToNCiAgICAgICAgICAgIGlmIGFueShmbm1hdGNoLmZubWF0Y2gobm9tZSwgcGFkKSBmb3IgcGFkIGluIEZPUkFfQVJRVUlWT1MpOg0KICAgICAgICAgICAgICAgIGNvbnRpbnVlDQogICAgICAgICAgICBpZiBuYV9yYWl6IGFuZCBhbnkoZm5tYXRjaC5mbm1hdGNoKG5vbWUsIHBhZCkgZm9yIHBhZCBpbiBGT1JBX0FSUVVJVk9TX1JBSVopOg0KICAgICAgICAgICAgICAgIGNvbnRpbnVlDQogICAgICAgICAgICBjYW1pbmhvID0gb3MucGF0aC5qb2luKHJhaXosIG5vbWUpDQogICAgICAgICAgICBpdGVucy5hcHBlbmQoKGNhbWluaG8sIG9zLnBhdGgucmVscGF0aChjYW1pbmhvLCBhcHApLnJlcGxhY2Uob3Muc2VwLCAiLyIpKSkNCiAgICByZXR1cm4gaXRlbnMNCg0KDQpkZWYgbW9udGFyX3ppcChhcHApOg0KICAgIGl0ZW5zID0gYXJxdWl2b3NfZG9fcGFjb3RlKGFwcCkNCiAgICBub21lcyA9IHtuIGZvciBfLCBuIGluIGl0ZW5zfQ0KICAgIGZhbHRhbSA9IFtvIGZvciBvIGluIE9CUklHQVRPUklPUyBpZiBvIG5vdCBpbiBub21lc10NCiAgICBpZiBmYWx0YW06DQogICAgICAgIHJhaXNlIFZhbHVlRXJyb3IoImZhbHRhbSBubyBhcHA6ICIgKyAiLCAiLmpvaW4oZmFsdGFtKSkNCiAgICBidWYgPSBpby5CeXRlc0lPKCkNCiAgICB3aXRoIHppcGZpbGUuWmlwRmlsZShidWYsICJ3IiwgemlwZmlsZS5aSVBfREVGTEFURUQpIGFzIHo6DQogICAgICAgIGZvciBjYW1pbmhvLCBub21lIGluIGl0ZW5zOg0KICAgICAgICAgICAgei53cml0ZShjYW1pbmhvLCBub21lKQ0KICAgIHJldHVybiBidWYuZ2V0dmFsdWUoKSwgbGVuKGl0ZW5zKQ0KDQoNCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSBtZW1icm9zIChpZ3VhbCBhbyB2OW9yYWNsZS9jb2xsZWN0b3IvY29mcmUucHkpDQpkZWYgaWRfbG9naW4obG9naW46IHN0cikgLT4gc3RyOg0KICAgIHJldHVybiBoYXNobGliLnNoYTI1Nihsb2dpbi5zdHJpcCgpLmxvd2VyKCkuZW5jb2RlKCJ1dGYtOCIpKS5oZXhkaWdlc3QoKQ0KDQoNCmRlZiBfZGVyaXZhKHNlbmhhOiBzdHIsIHNhbHQ6IGJ5dGVzLCBpdGVyYWNvZXM6IGludCkgLT4gYnl0ZXM6DQogICAgcmV0dXJuIGhhc2hsaWIucGJrZGYyX2htYWMoInNoYTI1NiIsIHNlbmhhLmVuY29kZSgidXRmLTgiKSwgc2FsdCwgaXRlcmFjb2VzLCAzMikNCg0KDQpkZWYgX2NoYXZlX2VjaWVzKHNoYXJlZDogYnl0ZXMsIGVwaF9wdWI6IGJ5dGVzLCBwdWI6IGJ5dGVzKSAtPiBieXRlczoNCiAgICByZXR1cm4gSEtERihhbGdvcml0aG09aGFzaGVzLlNIQTI1NigpLCBsZW5ndGg9MzIsIHNhbHQ9ZXBoX3B1YiArIHB1YiwgaW5mbz1iInY5LW9yYWNsZS1rIikuZGVyaXZlKHNoYXJlZCkNCg0KDQpkZWYgYWJyZV9tZW1icm8obWVtYnJvczogZGljdCwgbG9naW46IHN0ciwgc2VuaGE6IHN0cik6DQogICAgIiIiRGV2b2x2ZSBhIGNoYXZlIGRlIGRhZG9zIChiYXNlNjQpIHNlIGxvZ2luIGUgc2VuaGEgZXN0aXZlcmVtIGNlcnRvcywgc2VuYW8gTm9uZS4iIiINCiAgICBpZGVudCA9IGlkX2xvZ2luKGxvZ2luKQ0KICAgIGUgPSAobWVtYnJvcy5nZXQoIm1lbWJyb3MiKSBvciB7fSkuZ2V0KGlkZW50KQ0KICAgIGlmIG5vdCBlIG9yIG1lbWJyb3MuZ2V0KCJ2IikgIT0gMjoNCiAgICAgICAgcmV0dXJuIE5vbmUNCiAgICB0cnk6DQogICAgICAgIHdyYXAgPSBiYXNlNjQuYjY0ZGVjb2RlKGVbInByaXYiXSkNCiAgICAgICAgcHJpdiA9IEFFU0dDTShfZGVyaXZhKHNlbmhhLCBiYXNlNjQuYjY0ZGVjb2RlKGVbInNhbHQiXSksIGludChtZW1icm9zLmdldCgiaXRlciIsIElURVIpKSkpLmRlY3J5cHQoDQogICAgICAgICAgICB3cmFwWzoxMl0sIHdyYXBbMTI6XSwgaWRlbnQuZW5jb2RlKCkpDQogICAgICAgIGsgPSBiYXNlNjQuYjY0ZGVjb2RlKGVbImsiXSkNCiAgICAgICAgZXBoX3B1Yiwgbm9uY2UsIGN0ID0ga1s6MzJdLCBrWzMyOjQ0XSwga1s0NDpdDQogICAgICAgIHB1YiA9IGJhc2U2NC5iNjRkZWNvZGUoZVsicHViIl0pDQogICAgICAgIHNoYXJlZCA9IFgyNTUxOVByaXZhdGVLZXkuZnJvbV9wcml2YXRlX2J5dGVzKHByaXYpLmV4Y2hhbmdlKFgyNTUxOVB1YmxpY0tleS5mcm9tX3B1YmxpY19ieXRlcyhlcGhfcHViKSkNCiAgICAgICAgY2hhdmUgPSBBRVNHQ00oX2NoYXZlX2VjaWVzKHNoYXJlZCwgZXBoX3B1YiwgcHViKSkuZGVjcnlwdChub25jZSwgY3QsIGlkZW50LmVuY29kZSgpKQ0KICAgICAgICByZXR1cm4gYmFzZTY0LmI2NGVuY29kZShjaGF2ZSkuZGVjb2RlKCkNCiAgICBleGNlcHQgRXhjZXB0aW9uOg0KICAgICAgICByZXR1cm4gTm9uZQ0KDQoNCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLSBsaXN0YSBkbyBGbG93IChzbycgY29tcHJhZG9yZXMpDQojIE1lc21vIGZvcm1hdG8gZG8gdjlvcmFjbGUvY29sbGVjdG9yL2NvZnJlLnB5IChfZW50cmVnYV9jaGF2ZSwgX2V0aXF1ZXRhLCB0cm9jYV9jaGF2ZSksIGZpbHRyYW5kbyBxdWVtIGVudHJhLg0KZGVmIF94X3B1Yihwcml2OiBieXRlcykgLT4gYnl0ZXM6DQogICAgcmV0dXJuIFgyNTUxOVByaXZhdGVLZXkuZnJvbV9wcml2YXRlX2J5dGVzKHByaXYpLnB1YmxpY19rZXkoKS5wdWJsaWNfYnl0ZXMoRW5jb2RpbmcuUmF3LCBQdWJsaWNGb3JtYXQuUmF3KQ0KDQoNCmRlZiBfZW50cmVnYV9jaGF2ZShjaGF2ZTogYnl0ZXMsIHB1YjogYnl0ZXMsIGlkZW50OiBzdHIpIC0+IGJ5dGVzOg0KICAgIGVwaCA9IG9zLnVyYW5kb20oMzIpDQogICAgZXBoX3B1YiA9IF94X3B1YihlcGgpDQogICAgc2hhcmVkID0gWDI1NTE5UHJpdmF0ZUtleS5mcm9tX3ByaXZhdGVfYnl0ZXMoZXBoKS5leGNoYW5nZShYMjU1MTlQdWJsaWNLZXkuZnJvbV9wdWJsaWNfYnl0ZXMocHViKSkNCiAgICBub25jZSA9IG9zLnVyYW5kb20oMTIpDQogICAgcmV0dXJuIGVwaF9wdWIgKyBub25jZSArIEFFU0dDTShfY2hhdmVfZWNpZXMoc2hhcmVkLCBlcGhfcHViLCBwdWIpKS5lbmNyeXB0KG5vbmNlLCBjaGF2ZSwgaWRlbnQuZW5jb2RlKCkpDQoNCg0KZGVmIF9ldGlxdWV0YShjaGF2ZTogYnl0ZXMsIG5vbWU6IHN0ciwgaWRlbnQ6IHN0cikgLT4gYnl0ZXM6DQogICAgbm9uY2UgPSBvcy51cmFuZG9tKDEyKQ0KICAgIHJldHVybiBub25jZSArIEFFU0dDTShjaGF2ZSkuZW5jcnlwdChub25jZSwgbm9tZS5zdHJpcCgpLmVuY29kZSgidXRmLTgiKSwgYiJsYWJlbDoiICsgaWRlbnQuZW5jb2RlKCkpDQoNCg0KZGVmIF9sZV9ldGlxdWV0YShjaGF2ZV9iNjQ6IHN0ciwgaWRlbnQ6IHN0ciwgZTogZGljdCk6DQogICAgdHJ5Og0KICAgICAgICBsYWIgPSBiYXNlNjQuYjY0ZGVjb2RlKGVbImxhYmVsIl0pDQogICAgICAgIHJldHVybiBBRVNHQ00oYmFzZTY0LmI2NGRlY29kZShjaGF2ZV9iNjQpKS5kZWNyeXB0KGxhYls6MTJdLCBsYWJbMTI6XSwgYiJsYWJlbDoiICsgaWRlbnQuZW5jb2RlKCkpLmRlY29kZSgidXRmLTgiKQ0KICAgIGV4Y2VwdCBFeGNlcHRpb246DQogICAgICAgIHJldHVybiBOb25lDQoNCg0KZGVmIGxpc3RhX2NvbXByYWRvcmVzKG9yYWNsZTogZGljdCwgZmxvdywgY2hhdmVfb3JhY2xlX2I2NDogc3RyKSAtPiBsaXN0Og0KICAgICIiIlsoaWRlbnQsIG5vbWUsIGphX3RlbV9vX2Zsb3cpXSBkZSB0b2RvcyBvcyBtZW1icm9zIGRvIE9yYWNsZSwgZW0gb3JkZW0gZGUgbm9tZS4iIiINCiAgICBub19mbG93ID0gc2V0KCgoZmxvdyBvciB7fSkuZ2V0KCJtZW1icm9zIikgb3Ige30pLmtleXMoKSkNCiAgICBpdGVucyA9IFsoaWRlbnQsIF9sZV9ldGlxdWV0YShjaGF2ZV9vcmFjbGVfYjY0LCBpZGVudCwgZSkgb3IgIihzZW0gbm9tZSkiLCBpZGVudCBpbiBub19mbG93KQ0KICAgICAgICAgICAgIGZvciBpZGVudCwgZSBpbiAob3JhY2xlLmdldCgibWVtYnJvcyIpIG9yIHt9KS5pdGVtcygpXQ0KICAgIHJldHVybiBzb3J0ZWQoaXRlbnMsIGtleT1sYW1iZGEgeDogeFsxXS5sb3dlcigpKQ0KDQoNCmRlZiBtb250YV9saXN0YV9mbG93KG9yYWNsZTogZGljdCwgZXNjb2xoaWRvczogZGljdCwgY2hhdmVfZmxvd19iNjQ6IHN0cikgLT4gZGljdDoNCiAgICAiIiJlc2NvbGhpZG9zID0ge2lkZW50OiBub21lfS4gQ29waWEgZG8gT3JhY2xlIG8gcGFyIGRlIGNoYXZlcyBkZSBjYWRhIHVtIChzYWx0L3B1Yi9wcml2OiBvIGxvZ2luIGUgYSBzZW5oYSBjb250aW51YW0NCiAgICBvcyBtZXNtb3MpIGUgZW50cmVnYSBhIGNoYXZlIGRvIEZsb3cgbmEgY2hhdmUgcHVibGljYSBkZWxlLiIiIg0KICAgIGNoYXZlLCBiID0gYmFzZTY0LmI2NGRlY29kZShjaGF2ZV9mbG93X2I2NCksIChsYW1iZGEgeDogYmFzZTY0LmI2NGVuY29kZSh4KS5kZWNvZGUoKSkNCiAgICBvdXQgPSB7fQ0KICAgIGZvciBpZGVudCwgbm9tZSBpbiBlc2NvbGhpZG9zLml0ZW1zKCk6DQogICAgICAgIGUgPSBvcmFjbGVbIm1lbWJyb3MiXVtpZGVudF0NCiAgICAgICAgb3V0W2lkZW50XSA9IHsic2FsdCI6IGVbInNhbHQiXSwgInB1YiI6IGVbInB1YiJdLCAicHJpdiI6IGVbInByaXYiXSwNCiAgICAgICAgICAgICAgICAgICAgICAiayI6IGIoX2VudHJlZ2FfY2hhdmUoY2hhdmUsIGJhc2U2NC5iNjRkZWNvZGUoZVsicHViIl0pLCBpZGVudCkpLCAibGFiZWwiOiBiKF9ldGlxdWV0YShjaGF2ZSwgbm9tZSwgaWRlbnQpKX0NCiAgICByZXR1cm4geyJ2IjogMiwgImtkZiI6IG9yYWNsZS5nZXQoImtkZiIsICJQQktERjItU0hBMjU2IiksICJpdGVyIjogb3JhY2xlLmdldCgiaXRlciIsIElURVIpLCAibWVtYnJvcyI6IG91dH0NCg0KDQojIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0gcGFjb3RlIChmb3JtYXRvIFY5RTEpDQpkZWYgZmVjaGEoY2hhdmVfYjY0OiBzdHIsIGRhZG9zOiBieXRlcykgLT4gYnl0ZXM6DQogICAgbm9uY2UgPSBvcy51cmFuZG9tKDEyKQ0KICAgIHJldHVybiBNQUdJQyArIG5vbmNlICsgQUVTR0NNKGJhc2U2NC5iNjRkZWNvZGUoY2hhdmVfYjY0KSkuZW5jcnlwdChub25jZSwgZ3ppcC5jb21wcmVzcyhkYWRvcywgNiksIE5vbmUpDQoNCg0KZGVmIGFicmUoY2hhdmVfYjY0OiBzdHIsIGJsb2I6IGJ5dGVzKSAtPiBieXRlczoNCiAgICBpZiBibG9iWzo0XSAhPSBNQUdJQzoNCiAgICAgICAgcmFpc2UgVmFsdWVFcnJvcigiYXJxdWl2byBuYW8gZXN0YSBubyBmb3JtYXRvIGRvIHBhY290ZSIpDQogICAgbm9uY2UsIGN0ID0gYmxvYls0OjE2XSwgYmxvYlsxNjpdDQogICAgdHJ5Og0KICAgICAgICByZXR1cm4gZ3ppcC5kZWNvbXByZXNzKEFFU0dDTShiYXNlNjQuYjY0ZGVjb2RlKGNoYXZlX2I2NCkpLmRlY3J5cHQobm9uY2UsIGN0LCBOb25lKSkNCiAgICBleGNlcHQgSW52YWxpZFRhZzoNCiAgICAgICAgcmFpc2UgVmFsdWVFcnJvcigiYSBjaGF2ZSBuYW8gYWJyZSBlc3RlIHBhY290ZSAoYWNlc3NvIHJlbW92aWRvIG91IGNoYXZlIHRyb2NhZGEpIikNCg0KDQpkZWYgZXh0cmFpX3ppcChkYWRvczogYnl0ZXMsIGRlc3Rpbm86IHN0cikgLT4gaW50Og0KICAgICIiIkV4dHJhaSBvIHppcCByZWN1c2FuZG8gcXVhbHF1ZXIgY2FtaW5obyBxdWUgZXNjYXBlIGRhIHBhc3RhIGRlIGRlc3Rpbm8uIiIiDQogICAgZGVzdGlubyA9IG9zLnBhdGguYWJzcGF0aChkZXN0aW5vKQ0KICAgIHdpdGggemlwZmlsZS5aaXBGaWxlKGlvLkJ5dGVzSU8oZGFkb3MpKSBhcyB6Og0KICAgICAgICBmb3IgaW5mbyBpbiB6LmluZm9saXN0KCk6DQogICAgICAgICAgICBhbHZvID0gb3MucGF0aC5hYnNwYXRoKG9zLnBhdGguam9pbihkZXN0aW5vLCBpbmZvLmZpbGVuYW1lKSkNCiAgICAgICAgICAgIGlmIGFsdm8gIT0gZGVzdGlubyBhbmQgbm90IGFsdm8uc3RhcnRzd2l0aChkZXN0aW5vICsgb3Muc2VwKToNCiAgICAgICAgICAgICAgICByYWlzZSBWYWx1ZUVycm9yKCJwYWNvdGUgY29tIGNhbWluaG8gc3VzcGVpdG86ICIgKyBpbmZvLmZpbGVuYW1lKQ0KICAgICAgICB6LmV4dHJhY3RhbGwoZGVzdGlubykNCiAgICAgICAgcmV0dXJuIGxlbih6LmluZm9saXN0KCkpDQoNCg0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tIERQQVBJIChjaGF2ZSBndWFyZGFkYSBubyBjb21wdXRhZG9yIGRvIG1lbWJybykNCmNsYXNzIF9CbG9iKGN0eXBlcy5TdHJ1Y3R1cmUpOg0KICAgIF9maWVsZHNfID0gWygiY2JEYXRhIiwgY3R5cGVzLmNfdWludDMyKSwgKCJwYkRhdGEiLCBjdHlwZXMuUE9JTlRFUihjdHlwZXMuY19jaGFyKSldDQoNCg0KZGVmIHByb3RlZ2VyX2RwYXBpKGRhZG9zOiBieXRlcykgLT4gYnl0ZXM6DQogICAgIiIiUHJvdGVnZSBjb20gYSBjb250YSBkbyBXaW5kb3dzIGRvIHVzdWFyaW86IHNvJyBlbGUsIG5lc3RlIGNvbXB1dGFkb3IsIGNvbnNlZ3VlIGFicmlyLiIiIg0KICAgIGJ1ZiA9IGN0eXBlcy5jcmVhdGVfc3RyaW5nX2J1ZmZlcihkYWRvcywgbGVuKGRhZG9zKSkNCiAgICBlbnRyYWRhLCBzYWlkYSA9IF9CbG9iKGxlbihkYWRvcyksIGN0eXBlcy5jYXN0KGJ1ZiwgY3R5cGVzLlBPSU5URVIoY3R5cGVzLmNfY2hhcikpKSwgX0Jsb2IoKQ0KICAgIGlmIG5vdCBjdHlwZXMud2luZGxsLmNyeXB0MzIuQ3J5cHRQcm90ZWN0RGF0YShjdHlwZXMuYnlyZWYoZW50cmFkYSksICJWOUZsb3ciLCBOb25lLCBOb25lLCBOb25lLCAwLCBjdHlwZXMuYnlyZWYoc2FpZGEpKToNCiAgICAgICAgcmFpc2UgT1NFcnJvcigibyBXaW5kb3dzIHJlY3Vzb3UgYSBwcm90ZWNhbyAoRFBBUEkpIikNCiAgICB0cnk6DQogICAgICAgIHJldHVybiBjdHlwZXMuc3RyaW5nX2F0KHNhaWRhLnBiRGF0YSwgc2FpZGEuY2JEYXRhKQ0KICAgIGZpbmFsbHk6DQogICAgICAgIGN0eXBlcy53aW5kbGwua2VybmVsMzIuTG9jYWxGcmVlKGN0eXBlcy5jYXN0KHNhaWRhLnBiRGF0YSwgY3R5cGVzLmNfdm9pZF9wKSkNCg0KDQojIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0gY29tYW5kb3MNCmRlZiBfbGVyX21lbWJyb3MoY2FtaW5obyk6DQogICAgdHJ5Og0KICAgICAgICB3aXRoIG9wZW4oY2FtaW5obywgZW5jb2Rpbmc9InV0Zi04IikgYXMgZjoNCiAgICAgICAgICAgIG0gPSBqc29uLmxvYWQoZikNCiAgICAgICAgaWYgbS5nZXQoInYiKSAhPSAyOg0KICAgICAgICAgICAgcmFpc2UgVmFsdWVFcnJvcigiZm9ybWF0byBkZSBtZW1icm9zIG5hbyBzdXBvcnRhZG8iKQ0KICAgICAgICByZXR1cm4gbQ0KICAgIGV4Y2VwdCAoT1NFcnJvciwgVmFsdWVFcnJvcikgYXMgZToNCiAgICAgICAgcHJpbnQoZiJFUlJPOiBuYW8gY29uc2VndWkgbGVyIHtjYW1pbmhvfSAoe2V9KSIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgcmV0dXJuIE5vbmUNCg0KDQpkZWYgX2xlcl9jcmVkZW5jaWFpcygpOg0KICAgIGxvZ2luID0gKHN5cy5zdGRpbi5yZWFkbGluZSgpIG9yICIiKS5yc3RyaXAoIlxyXG4iKQ0KICAgIHNlbmhhID0gKHN5cy5zdGRpbi5yZWFkbGluZSgpIG9yICIiKS5yc3RyaXAoIlxyXG4iKQ0KICAgIHJldHVybiBsb2dpbiwgc2VuaGENCg0KDQpkZWYgY21kX2FicmlyKGEpOg0KICAgIG1lbWJyb3MgPSBfbGVyX21lbWJyb3MoYS5tZW1icm9zKQ0KICAgIGlmIG1lbWJyb3MgaXMgTm9uZToNCiAgICAgICAgcmV0dXJuIDMNCiAgICBsb2dpbiwgc2VuaGEgPSBfbGVyX2NyZWRlbmNpYWlzKCkNCiAgICBjaGF2ZSA9IGFicmVfbWVtYnJvKG1lbWJyb3MsIGxvZ2luLCBzZW5oYSkgaWYgbG9naW4gYW5kIHNlbmhhIGVsc2UgTm9uZQ0KICAgIGlmIG5vdCBjaGF2ZToNCiAgICAgICAgcmV0dXJuIDINCiAgICBwcmludChjaGF2ZSkNCiAgICByZXR1cm4gMA0KDQoNCmRlZiBjbWRfZGVjaWZyYXIoYSk6DQogICAgY2hhdmUgPSAoc3lzLnN0ZGluLnJlYWRsaW5lKCkgb3IgIiIpLnN0cmlwKCkNCiAgICB0cnk6DQogICAgICAgIHdpdGggb3BlbihhLnBhY290ZSwgInJiIikgYXMgZjoNCiAgICAgICAgICAgIGJsb2IgPSBmLnJlYWQoKQ0KICAgIGV4Y2VwdCBPU0Vycm9yIGFzIGU6DQogICAgICAgIHByaW50KGYiRVJSTzogbmFvIGNvbnNlZ3VpIGxlciBvIHBhY290ZSAoe2V9KSIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgcmV0dXJuIDMNCiAgICB0cnk6DQogICAgICAgIG4gPSBleHRyYWlfemlwKGFicmUoY2hhdmUsIGJsb2IpLCBhLmRlc3Rpbm8pDQogICAgZXhjZXB0IEV4Y2VwdGlvbiBhcyBlOg0KICAgICAgICBwcmludChmIkVSUk86IHtlfSIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgcmV0dXJuIDQNCiAgICBwcmludChmIntufSBhcnF1aXZvKHMpIGV4dHJhaWRvKHMpIGVtIHthLmRlc3Rpbm99IikNCiAgICByZXR1cm4gMA0KDQoNCmRlZiBjbWRfZ3VhcmRhcihhKToNCiAgICBjaGF2ZSA9IChzeXMuc3RkaW4ucmVhZGxpbmUoKSBvciAiIikuc3RyaXAoKQ0KICAgIHRyeToNCiAgICAgICAgYmFzZTY0LmI2NGRlY29kZShjaGF2ZSwgdmFsaWRhdGU9VHJ1ZSkNCiAgICAgICAgb3MubWFrZWRpcnMob3MucGF0aC5kaXJuYW1lKG9zLnBhdGguYWJzcGF0aChhLmRlc3Rpbm8pKSwgZXhpc3Rfb2s9VHJ1ZSkNCiAgICAgICAgd2l0aCBvcGVuKGEuZGVzdGlubywgIndiIikgYXMgZjoNCiAgICAgICAgICAgIGYud3JpdGUocHJvdGVnZXJfZHBhcGkoY2hhdmUuZW5jb2RlKCJhc2NpaSIpKSkNCiAgICBleGNlcHQgKFZhbHVlRXJyb3IsIE9TRXJyb3IpIGFzIGU6DQogICAgICAgIHByaW50KGYiRVJSTzogbmFvIGNvbnNlZ3VpIGd1YXJkYXIgYSBjaGF2ZSAoe2V9KSIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgcmV0dXJuIDMNCiAgICBwcmludCgiY2hhdmUgZ3VhcmRhZGEiKQ0KICAgIHJldHVybiAwDQoNCg0KZGVmIGNtZF9saXN0YXIoYSk6DQogICAgaXRlbnMgPSBhcnF1aXZvc19kb19wYWNvdGUoYS5hcHApDQogICAgZm9yIF8sIG5vbWUgaW4gaXRlbnM6DQogICAgICAgIHByaW50KG5vbWUpDQogICAgcHJpbnQoZiItLSB7bGVuKGl0ZW5zKX0gYXJxdWl2byhzKSIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICByZXR1cm4gMA0KDQoNCmRlZiBjbWRfY29tcHJhZG9yZXMoYSk6DQogICAgb3JhY2xlID0gX2xlcl9tZW1icm9zKGEub3JhY2xlKQ0KICAgIGlmIG9yYWNsZSBpcyBOb25lOg0KICAgICAgICByZXR1cm4gMw0KICAgIGZsb3cgPSBOb25lDQogICAgaWYgb3MucGF0aC5leGlzdHMoYS5mbG93KToNCiAgICAgICAgZmxvdyA9IF9sZXJfbWVtYnJvcyhhLmZsb3cpDQogICAgICAgIGlmIGZsb3cgaXMgTm9uZToNCiAgICAgICAgICAgIHJldHVybiAzDQogICAgbG9naW4sIHNlbmhhID0gX2xlcl9jcmVkZW5jaWFpcygpDQogICAga19vcmFjbGUgPSBhYnJlX21lbWJybyhvcmFjbGUsIGxvZ2luLCBzZW5oYSkgaWYgbG9naW4gYW5kIHNlbmhhIGVsc2UgTm9uZQ0KICAgIGlmIG5vdCBrX29yYWNsZToNCiAgICAgICAgcHJpbnQoIkVSUk86IGxvZ2luIG91IHNlbmhhIGluY29ycmV0b3MuIiwgZmlsZT1zeXMuc3RkZXJyKQ0KICAgICAgICByZXR1cm4gMg0KICAgIGtfZmxvdyA9IE5vbmUNCiAgICBpZiBmbG93Og0KICAgICAgICBrX2Zsb3cgPSBhYnJlX21lbWJybyhmbG93LCBsb2dpbiwgc2VuaGEpDQogICAgICAgIGlmIG5vdCBrX2Zsb3c6DQogICAgICAgICAgICBwcmludCgiRVJSTzogZXN0ZSBsb2dpbiBuYW8gZXN0YSBuYSBsaXN0YSBkbyBWOSBGbG93LiBTbycgcXVlbSBqYSBhZG1pbmlzdHJhIG8gVjkgRmxvdyBtdWRhIGEgbGlzdGEuIiwNCiAgICAgICAgICAgICAgICAgIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgICAgIHJldHVybiAyDQogICAgICAgIGlmIGtfZmxvdyA9PSBrX29yYWNsZTogICAgICAjIGxpc3RhIGFudGlnYSwgY29waWFkYSBpbnRlaXJhIGRvIE9yYWNsZTogYSBjaGF2ZSBkbyBPcmFjbGUgbnVuY2EgYWJyZSBvIEZsb3cNCiAgICAgICAgICAgIGtfZmxvdyA9IE5vbmUNCiAgICBpdGVucyA9IGxpc3RhX2NvbXByYWRvcmVzKG9yYWNsZSwgZmxvdywga19vcmFjbGUpDQogICAgZXUgPSBpZF9sb2dpbihsb2dpbikNCg0KICAgIGlmIGEuZXNjb2xoYSBpcyBOb25lOg0KICAgICAgICBmb3IgbiwgKGlkZW50LCBub21lLCBqYSkgaW4gZW51bWVyYXRlKGl0ZW5zLCAxKToNCiAgICAgICAgICAgIHByaW50KGYie246PjN9LiBbeyd4JyBpZiBqYSBlbHNlICcgJ31dIHtub21lfXsnICAodm9jZSknIGlmIGlkZW50ID09IGV1IGVsc2UgJyd9IikNCiAgICAgICAgcmV0dXJuIDANCg0KICAgIGlmIGEuZXNjb2xoYS5zdHJpcCgpLmxvd2VyKCkgPT0gInRvZG9zIjogICAgICAgICMgdG9kbyBtZW1icm8gZG8gT3JhY2xlIChvIHBhZHJhbyBjb250aW51YTogc28nIHF1ZW0gY29tcHJvdSkNCiAgICAgICAgaWRlbnRzID0ge2kgZm9yIGksIF8sIF8gaW4gaXRlbnN9DQogICAgZWxpZiBhLmVzY29saGEuc3RyaXAoKSA9PSAiPSI6DQogICAgICAgIGlmIG5vdCBmbG93Og0KICAgICAgICAgICAgcHJpbnQoIkVSUk86IGFpbmRhIG5hbyBleGlzdGUgbGlzdGEgZG8gVjkgRmxvdy4gRGlnaXRlIG9zIG51bWVyb3MgZGUgcXVlbSBjb21wcm91LiIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgICAgIHJldHVybiAzDQogICAgICAgIGlkZW50cyA9IHtpIGZvciBpLCBfLCBqYSBpbiBpdGVucyBpZiBqYX0NCiAgICBlbHNlOg0KICAgICAgICB0cnk6DQogICAgICAgICAgICBudW1zID0gW2ludCh4KSBmb3IgeCBpbiByZS5zcGxpdChyIlssO1xzXSsiLCBhLmVzY29saGEuc3RyaXAoKSkgaWYgeF0NCiAgICAgICAgZXhjZXB0IFZhbHVlRXJyb3I6DQogICAgICAgICAgICBwcmludCgiRVJSTzogZGlnaXRlIHNvJyBvcyBudW1lcm9zLCBzZXBhcmFkb3MgcG9yIHZpcmd1bGEgKGV4LjogMSwzLDUpLiIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgICAgIHJldHVybiAzDQogICAgICAgIGZvcmEgPSBbbiBmb3IgbiBpbiBudW1zIGlmIG5vdCAxIDw9IG4gPD0gbGVuKGl0ZW5zKV0NCiAgICAgICAgaWYgZm9yYToNCiAgICAgICAgICAgIHByaW50KGYiRVJSTzogbnVtZXJvIGZvcmEgZGEgbGlzdGE6IHsnLCAnLmpvaW4obWFwKHN0ciwgZm9yYSkpfS4iLCBmaWxlPXN5cy5zdGRlcnIpDQogICAgICAgICAgICByZXR1cm4gMw0KICAgICAgICBpZGVudHMgPSB7aXRlbnNbbiAtIDFdWzBdIGZvciBuIGluIG51bXN9DQogICAgaWRlbnRzLmFkZChldSkgICAgICAgICAgICAgICAgICAjIG8gYWRtaW5pc3RyYWRvciBmaWNhIHNlbXByZTogZScgbyBsb2dpbiBkZWxlIHF1ZSBhYnJlIGEgY2hhdmUgcGFyYSBwdWJsaWNhcg0KDQogICAgdHJvY291ID0ga19mbG93IGlzIG5vdCBOb25lIGFuZCBhLnRyb2Nhcl9jaGF2ZQ0KICAgIGlmIGtfZmxvdyBpcyBOb25lIG9yIGEudHJvY2FyX2NoYXZlOg0KICAgICAgICBrX2Zsb3cgPSBiYXNlNjQuYjY0ZW5jb2RlKG9zLnVyYW5kb20oMzIpKS5kZWNvZGUoKQ0KICAgIG5vbWVzID0ge2k6IG4gZm9yIGksIG4sIF8gaW4gaXRlbnN9DQogICAgbGlzdGEgPSBtb250YV9saXN0YV9mbG93KG9yYWNsZSwge2k6IG5vbWVzW2ldIGZvciBpIGluIGlkZW50c30sIGtfZmxvdykNCiAgICBvcy5tYWtlZGlycyhvcy5wYXRoLmRpcm5hbWUob3MucGF0aC5hYnNwYXRoKGEuZmxvdykpLCBleGlzdF9vaz1UcnVlKQ0KICAgIHdpdGggb3BlbihhLmZsb3csICJ3IiwgZW5jb2Rpbmc9InV0Zi04IikgYXMgZjoNCiAgICAgICAganNvbi5kdW1wKGxpc3RhLCBmLCBpbmRlbnQ9MSkNCg0KICAgIHByaW50KGYiTGlzdGEgZG8gVjkgRmxvdzoge2xlbihpZGVudHMpfSBwZXNzb2EocyksIHZvY2UgaW5jbHVpZG8uIikNCiAgICBmb3Igbm9tZSBpbiBzb3J0ZWQoKG5vbWVzW2ldIGZvciBpIGluIGlkZW50cyksIGtleT1zdHIubG93ZXIpOg0KICAgICAgICBwcmludChmIiAgLSB7bm9tZX0iKQ0KICAgIHJlbW92aWRvcyA9IHtpIGZvciBpLCBfLCBqYSBpbiBpdGVucyBpZiBqYX0gLSBpZGVudHMNCiAgICBpZiByZW1vdmlkb3MgYW5kIG5vdCB0cm9jb3U6DQogICAgICAgIHByaW50KGYiQVZJU086IHtsZW4ocmVtb3ZpZG9zKX0gcGVzc29hKHMpIHNhaXJhbSBkYSBsaXN0YS4gRWxhcyBuYW8gaW5zdGFsYW0gbWFpcywgbWFzIHF1ZW0gamEgdGluaGEgaW5zdGFsYWRvICINCiAgICAgICAgICAgICAgImd1YXJkYSBhIGNoYXZlIGF0dWFsIGUgY29udGludWEgcmVjZWJlbmRvIGFzIHZlcnNvZXMgbm92YXMgYXRlIHZvY2UgdHJvY2FyIGEgY2hhdmUuIikNCiAgICBpZiB0cm9jb3U6DQogICAgICAgIHByaW50KCJDaGF2ZSBkbyBWOSBGbG93IHRyb2NhZGE6IHF1ZW0gamEgdGluaGEgaW5zdGFsYWRvIHByZWNpc2Egcm9kYXIgbyBpbnN0YWxhZG9yIGRlIG5vdm8gcGFyYSByZWNlYmVyIGFzICINCiAgICAgICAgICAgICAgInZlcnNvZXMgbm92YXMuIikNCiAgICByZXR1cm4gMA0KDQoNCmRlZiBjbWRfcHVibGljYXIoYSk6DQogICAgbWVtYnJvcyA9IF9sZXJfbWVtYnJvcyhhLm1lbWJyb3MpDQogICAgaWYgbWVtYnJvcyBpcyBOb25lOg0KICAgICAgICByZXR1cm4gMw0KICAgIHRyeToNCiAgICAgICAgdmVyc2FvID0gYS52ZXJzYW8gb3Igb3Blbihvcy5wYXRoLmpvaW4oYS5hcHAsICJWRVJTQU8iKSwgZW5jb2Rpbmc9InV0Zi04IikucmVhZCgpLnN0cmlwKCkNCiAgICBleGNlcHQgT1NFcnJvcjoNCiAgICAgICAgdmVyc2FvID0gIiINCiAgICBpZiBub3QgdmVyc2FvOg0KICAgICAgICBwcmludCgiRVJSTzogbyBhcnF1aXZvIFZFUlNBTyBkbyBhcHAgZXN0YSB2YXppbyBvdSBuYW8gZXhpc3RlLiIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgcmV0dXJuIDMNCiAgICB0cnk6DQogICAgICAgIHdpdGggb3Blbihvcy5wYXRoLmpvaW4oYS5kaXN0LCAibGF0ZXN0Lmpzb24iKSwgZW5jb2Rpbmc9InV0Zi04IikgYXMgZjoNCiAgICAgICAgICAgIHB1YmxpY2FkYSA9IChqc29uLmxvYWQoZikgb3Ige30pLmdldCgidmVyc2FvIiwgIiIpDQogICAgZXhjZXB0IChPU0Vycm9yLCBWYWx1ZUVycm9yKToNCiAgICAgICAgcHVibGljYWRhID0gIiINCiAgICBpZiBwdWJsaWNhZGEgPT0gdmVyc2FvOg0KICAgICAgICBwcmludChmIkVSUk86IGEgdmVyc2FvIHt2ZXJzYW99IGphIGVzdGEgcHVibGljYWRhLiBBdW1lbnRlIG8gbnVtZXJvIG5vIGFycXVpdm8gVkVSU0FPIChleC46IDAuMikgZSByb2RlIGRlIG5vdm86XG4iDQogICAgICAgICAgICAgICIgICAgICBzZW0gdmVyc2FvIG5vdmEsIHF1ZW0gamEgaW5zdGFsb3UgbmFvIHJlY2ViZSBhIGF0dWFsaXphY2FvLiIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgcmV0dXJuIDYNCiAgICBsb2dpbiwgc2VuaGEgPSBfbGVyX2NyZWRlbmNpYWlzKCkNCiAgICBjaGF2ZSA9IGFicmVfbWVtYnJvKG1lbWJyb3MsIGxvZ2luLCBzZW5oYSkgaWYgbG9naW4gYW5kIHNlbmhhIGVsc2UgTm9uZQ0KICAgIGlmIG5vdCBjaGF2ZToNCiAgICAgICAgcHJpbnQoIkVSUk86IGxvZ2luIG91IHNlbmhhIGluY29ycmV0b3MuIiwgZmlsZT1zeXMuc3RkZXJyKQ0KICAgICAgICByZXR1cm4gMg0KICAgIHRyeToNCiAgICAgICAgemlwX2J5dGVzLCBuID0gbW9udGFyX3ppcChhLmFwcCkNCiAgICBleGNlcHQgKFZhbHVlRXJyb3IsIE9TRXJyb3IpIGFzIGU6DQogICAgICAgIHByaW50KGYiRVJSTzogbmFvIGNvbnNlZ3VpIG1vbnRhciBvIHBhY290ZSAoe2V9KSIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgcmV0dXJuIDMNCiAgICAjIE1FVE9ETyBOQSBOVVZFTSAoMjAyNi0xMC0xMyk6IG9zIHByb21wdHMgZG8gYWdlbnRlIGUgZG8gZXN0dWRpbyBlIGFzIHJlZmVyZW5jaWFzIENFTkEvR0VOSVUkIHZhbyBwYXJhIG8gU3VwYWJhc2UNCiAgICAjIChpbnN0YWxhZG9yL2NvbnRldWRvX251dmVtLnB5KSBlIHNhZW0gZG8gcGFjb3RlIGRvcyBtZW1icm9zLiBTZSBhIG51dmVtIGZhbGhhciwgbmFkYSBlJyBwdWJsaWNhZG8uDQogICAgaWYgZ2V0YXR0cihhLCAibWV0b2RvX251dmVtIiwgRmFsc2UpOg0KICAgICAgICB0cnk6DQogICAgICAgICAgICBzeXMucGF0aC5pbnNlcnQoMCwgb3MucGF0aC5kaXJuYW1lKG9zLnBhdGguYWJzcGF0aChfX2ZpbGVfXykpKQ0KICAgICAgICAgICAgaW1wb3J0IGNvbnRldWRvX251dmVtIGFzIENODQogICAgICAgICAgICBwYWNvdGUgPSBDTi5tb250YXIoYS5hcHApDQogICAgICAgICAgICB6aXBfYnl0ZXMsIGsgPSBDTi50aXJhcl9kb196aXAoemlwX2J5dGVzLCBwYWNvdGUpDQogICAgICAgICAgICBvaywgbXNnID0gQ04ucHVibGljYXIocGFjb3RlKQ0KICAgICAgICBleGNlcHQgKEV4Y2VwdGlvbiwgU3lzdGVtRXhpdCkgYXMgZToNCiAgICAgICAgICAgIHByaW50KGYiRVJSTzogbmFvIGNvbnNlZ3VpIHRpcmFyIG8gbWV0b2RvIGRvIHBhY290ZSAoe2V9KS4gTmFkYSBmb2kgcHVibGljYWRvLiIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgICAgIHJldHVybiA3DQogICAgICAgIGlmIG5vdCBvazoNCiAgICAgICAgICAgIHByaW50KG1zZyArICIgTmFkYSBmb2kgcHVibGljYWRvLiIsIGZpbGU9c3lzLnN0ZGVycikNCiAgICAgICAgICAgIHJldHVybiA3DQogICAgICAgIHByaW50KG1zZykNCiAgICAgICAgcHJpbnQoZiJNZXRvZG8gZm9yYSBkbyBwYWNvdGU6IHtrfSBwcm9tcHQocykgZSBhcnF1aXZvKHMpIHNvJyBuYSBudXZlbS4iKQ0KICAgIGJsb2IgPSBmZWNoYShjaGF2ZSwgemlwX2J5dGVzKQ0KICAgIG9zLm1ha2VkaXJzKGEuZGlzdCwgZXhpc3Rfb2s9VHJ1ZSkNCiAgICB3aXRoIG9wZW4ob3MucGF0aC5qb2luKGEuZGlzdCwgQVJRVUlWT19QQUNPVEUpLCAid2IiKSBhcyBmOg0KICAgICAgICBmLndyaXRlKGJsb2IpDQogICAgbGF0ZXN0ID0geyJ2ZXJzYW8iOiB2ZXJzYW8sICJhcnF1aXZvIjogQVJRVUlWT19QQUNPVEUsICJzaGEyNTYiOiBoYXNobGliLnNoYTI1NihibG9iKS5oZXhkaWdlc3QoKSwNCiAgICAgICAgICAgICAgInRhbWFuaG8iOiBsZW4oYmxvYiksICJwdWJsaWNhZG9fZW0iOiB0aW1lLnN0cmZ0aW1lKCIlWS0lbS0lZCAlSDolTTolUyIpLA0KICAgICAgICAgICAgICAiY2hhdmVfaWQiOiBoYXNobGliLnNoYTI1NihiYXNlNjQuYjY0ZGVjb2RlKGNoYXZlKSkuaGV4ZGlnZXN0KClbOjEyXX0NCiAgICB3aXRoIG9wZW4ob3MucGF0aC5qb2luKGEuZGlzdCwgImxhdGVzdC5qc29uIiksICJ3IiwgZW5jb2Rpbmc9InV0Zi04IikgYXMgZjoNCiAgICAgICAganNvbi5kdW1wKGxhdGVzdCwgZiwgaW5kZW50PTEpDQogICAgZGVzdGlubyA9IG9zLnBhdGguam9pbihhLmRpc3QsICJtZW1icm9zLmpzb24iKQ0KICAgIGlmIG9zLnBhdGguYWJzcGF0aChhLm1lbWJyb3MpICE9IG9zLnBhdGguYWJzcGF0aChkZXN0aW5vKTogICAjIGEgbGlzdGEgZG8gRmxvdyBqYSBtb3JhIG5vIGRpc3Q6IG5hbyBjb3BpYSBzb2JyZSBzaQ0KICAgICAgICB3aXRoIG9wZW4oYS5tZW1icm9zLCAicmIiKSBhcyBvOg0KICAgICAgICAgICAgZGFkb3MgPSBvLnJlYWQoKQ0KICAgICAgICB3aXRoIG9wZW4oZGVzdGlubywgIndiIikgYXMgZDoNCiAgICAgICAgICAgIGQud3JpdGUoZGFkb3MpDQogICAgcHJpbnQoZiJQYWNvdGUge3ZlcnNhb306IHtufSBhcnF1aXZvKHMpLCB7bGVuKGJsb2IpIC8gMTAyNDouMGZ9IEtCIGNpZnJhZG8gLT4ge2EuZGlzdH0iKQ0KICAgIHJldHVybiAwDQoNCg0KZGVmIG1haW4oKToNCiAgICBhcCA9IGFyZ3BhcnNlLkFyZ3VtZW50UGFyc2VyKGRlc2NyaXB0aW9uPSJDb2ZyZSBkbyBpbnN0YWxhZG9yIFY5IEZsb3ciKQ0KICAgIHN1YiA9IGFwLmFkZF9zdWJwYXJzZXJzKGRlc3Q9ImNtZCIsIHJlcXVpcmVkPVRydWUpDQogICAgcCA9IHN1Yi5hZGRfcGFyc2VyKCJhYnJpciIpOyBwLmFkZF9hcmd1bWVudCgiLS1tZW1icm9zIiwgcmVxdWlyZWQ9VHJ1ZSk7IHAuc2V0X2RlZmF1bHRzKGY9Y21kX2FicmlyKQ0KICAgIHAgPSBzdWIuYWRkX3BhcnNlcigiZGVjaWZyYXIiKTsgcC5hZGRfYXJndW1lbnQoIi0tcGFjb3RlIiwgcmVxdWlyZWQ9VHJ1ZSk7IHAuYWRkX2FyZ3VtZW50KCItLWRlc3Rpbm8iLCByZXF1aXJlZD1UcnVlKQ0KICAgIHAuc2V0X2RlZmF1bHRzKGY9Y21kX2RlY2lmcmFyKQ0KICAgIHAgPSBzdWIuYWRkX3BhcnNlcigiZ3VhcmRhciIpOyBwLmFkZF9hcmd1bWVudCgiLS1kZXN0aW5vIiwgcmVxdWlyZWQ9VHJ1ZSk7IHAuc2V0X2RlZmF1bHRzKGY9Y21kX2d1YXJkYXIpDQogICAgcCA9IHN1Yi5hZGRfcGFyc2VyKCJsaXN0YXIiKTsgcC5hZGRfYXJndW1lbnQoIi0tYXBwIiwgcmVxdWlyZWQ9VHJ1ZSk7IHAuc2V0X2RlZmF1bHRzKGY9Y21kX2xpc3RhcikNCiAgICBwID0gc3ViLmFkZF9wYXJzZXIoImNvbXByYWRvcmVzIik7IHAuYWRkX2FyZ3VtZW50KCItLW9yYWNsZSIsIHJlcXVpcmVkPVRydWUpOyBwLmFkZF9hcmd1bWVudCgiLS1mbG93IiwgcmVxdWlyZWQ9VHJ1ZSkNCiAgICBwLmFkZF9hcmd1bWVudCgiLS1lc2NvbGhhIik7IHAuYWRkX2FyZ3VtZW50KCItLXRyb2Nhci1jaGF2ZSIsIGFjdGlvbj0ic3RvcmVfdHJ1ZSIsIGRlc3Q9InRyb2Nhcl9jaGF2ZSIpDQogICAgcC5zZXRfZGVmYXVsdHMoZj1jbWRfY29tcHJhZG9yZXMpDQogICAgcCA9IHN1Yi5hZGRfcGFyc2VyKCJwdWJsaWNhciIpOyBwLmFkZF9hcmd1bWVudCgiLS1hcHAiLCByZXF1aXJlZD1UcnVlKTsgcC5hZGRfYXJndW1lbnQoIi0tZGlzdCIsIHJlcXVpcmVkPVRydWUpDQogICAgcC5hZGRfYXJndW1lbnQoIi0tbWVtYnJvcyIsIHJlcXVpcmVkPVRydWUpOyBwLmFkZF9hcmd1bWVudCgiLS12ZXJzYW8iKQ0KICAgIHAuYWRkX2FyZ3VtZW50KCItLW1ldG9kby1udXZlbSIsIGFjdGlvbj0ic3RvcmVfdHJ1ZSIsIGRlc3Q9Im1ldG9kb19udXZlbSIpDQogICAgcC5zZXRfZGVmYXVsdHMoZj1jbWRfcHVibGljYXIpDQogICAgYSA9IGFwLnBhcnNlX2FyZ3MoKQ0KICAgIHJldHVybiBhLmYoYSkNCg0KDQppZiBfX25hbWVfXyA9PSAiX19tYWluX18iOg0KICAgIHN5cy5leGl0KG1haW4oKSkNCg=='
# ==========================================================================

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Nome = 'V9 Flow'
$Avisos = New-Object System.Collections.ArrayList

# --- modo de teste (so' para quem desenvolve): troca origem e destino e dispensa as perguntas
$Teste = ($env:V9F_MODO_TESTE -eq '1')
if ($Teste -and $env:V9F_BASE_URL) { $BaseUrl = $env:V9F_BASE_URL.TrimEnd('/') }
if (-not $BaseUrl) { $BaseUrl = "https://raw.githubusercontent.com/$Dist/main" }
# --- modo encadeado (2026-10-13): o instalador do V9 Vision baixa este arquivo e roda logo depois de instalar o V9
# Vision. O login, a senha, o aceite do termo e a unidade vem de la (V9F_E_*), para nao perguntar tudo de novo.
$Encadeado = ($env:V9F_ENCADEADO -eq '1')
# pasta de dados do V9 Flow (config, fila, perfil do navegador, chave): a mesma que o app usa
$Dados = Join-Path $env:LOCALAPPDATA 'V9Flow'
if ($Teste -and $env:V9FLOW_DADOS) { $Dados = $env:V9FLOW_DADOS }

function Passo($n, $t) { Write-Host ''; Write-Host "[$n/7] $t" -ForegroundColor Cyan }
function Ok($t)        { Write-Host "      OK -- $t" -ForegroundColor Green }
function Alerta($t)    { Write-Host "      AVISO: $t" -ForegroundColor Yellow; [void]$Avisos.Add($t) }
function Parar($t) {
    Write-Host ''
    Write-Host "ERRO: $t" -ForegroundColor Red
    Write-Host 'A instalacao NAO foi concluida. Pode rodar este instalador de novo depois de resolver.'
    exit 1
}
function AtualizarPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path', 'User')
}
function Tem($comando) { [bool](Get-Command $comando -ErrorAction SilentlyContinue) }
function VersaoOk($exe) {
    try { $v = (& $exe --version 2>&1) -join '' } catch { return $false }
    return ($v -match 'Python 3\.(\d+)' -and [int]$Matches[1] -ge 10)
}
function PythonOk {
    $c = Get-Command python -ErrorAction SilentlyContinue
    # o "python" da pasta WindowsApps e' so' um atalho para a loja, nao e' o Python
    if ($c -and $c.Source -notlike '*\WindowsApps\*' -and (VersaoOk 'python')) { return $true }
    # Python instalado mas FORA do PATH: procura pelo lancador "py" e nas pastas de usuario e da maquina
    $achados = @()
    if (Tem 'py') { try { $achados += (& py -3 -c "import sys; print(sys.executable)" 2>$null) } catch {} }
    foreach ($base in @("$env:LOCALAPPDATA\Programs\Python", "$env:ProgramFiles", "${env:ProgramFiles(x86)}")) {
        if (Test-Path $base) {
            $achados += Get-ChildItem $base -Directory -Filter 'Python3*' -ErrorAction SilentlyContinue |
                Sort-Object Name -Descending | ForEach-Object { Join-Path $_.FullName 'python.exe' }
        }
    }
    foreach ($exe in $achados) {
        if ($exe -and (Test-Path $exe) -and (VersaoOk $exe)) {
            $dir = Split-Path $exe
            $env:Path = "$dir;$dir\Scripts;" + $env:Path
            Write-Host "      (Python achado fora do PATH: $exe)"
            return $true
        }
    }
    return $false
}
function Perguntar($texto, $padrao = '', $id = '') {
    if ($Encadeado -and $id -and (Test-Path "env:V9F_E_$id")) { return (Get-Item "env:V9F_E_$id").Value }
    if ($Teste) { if ($id -and (Test-Path "env:V9F_R_$id")) { return (Get-Item "env:V9F_R_$id").Value } else { return $padrao } }
    $r = Read-Host $texto
    if ([string]::IsNullOrWhiteSpace($r)) { return $padrao }
    return $r.Trim().Trim('"')
}
function LerSegredo($texto, $id = '') {
    if ($Encadeado -and $id -and (Test-Path "env:V9F_E_$id")) {
        $v = (Get-Item "env:V9F_E_$id").Value
        Remove-Item "env:V9F_E_$id" -ErrorAction SilentlyContinue      # uma vez so': se estiver errada, pergunta
        return $v
    }
    if ($Teste) { if ($id -and (Test-Path "env:V9F_R_$id")) { return (Get-Item "env:V9F_R_$id").Value } else { return '' } }
    $s = Read-Host $texto -AsSecureString
    $b = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
}
# o V9 Flow aberto segura a trava v9flow.lock na pasta de dados: se nao da' para abrir o arquivo com exclusividade, esta aberto
function FlowAberto {
    $trava = Join-Path $Dados 'v9flow.lock'
    if (-not (Test-Path $trava)) { return $false }
    try { $f = [IO.File]::Open($trava, 'Open', 'ReadWrite', 'None'); $f.Close(); return $false } catch { return $true }
}

Write-Host '=============================================================='
Write-Host "  Instalador do $Nome"
Write-Host '  Leva de 2 a 10 minutos, depende da internet.'
Write-Host '  Se o Windows pedir permissao (tela escura com Sim/Nao), clique Sim.'
Write-Host '=============================================================='
AtualizarPath

# ---------- onde instalar ----------
$Lembrete = Join-Path $Dados 'destino.txt'
function UnidadesFixas {
    [IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq 'Fixed' -and $_.IsReady } |
        ForEach-Object { [pscustomobject]@{ Letra = $_.Name.Substring(0, 1).ToUpper(); LivreGB = [math]::Round($_.AvailableFreeSpace / 1GB) } }
}
function EhDoFlow($d) { return (Test-Path (Join-Path $d 'v9flow\__main__.py')) }
function EscolherDestino {
    if ($Teste -and $env:V9F_DESTINO) { return $env:V9F_DESTINO }
    if (Test-Path $Lembrete) {
        $d = (Get-Content $Lembrete -Raw).Trim()
        if ($d -and (EhDoFlow $d)) {
            Write-Host "      Instalacao encontrada em $d (sera atualizada)."
            return $d
        }
    }
    $un = @(UnidadesFixas)
    Write-Host ''
    Write-Host '  Onde instalar o V9 Flow?'
    Write-Host '  O programa ocupa cerca de 300 MB (com o navegador proprio, que ele baixa na primeira vez).'
    foreach ($u in $un) { Write-Host ('      {0}:   {1} GB livres' -f $u.Letra, $u.LivreGB) }
    for (;;) {
        $r = Perguntar '      Digite a letra da unidade (Enter = C) ou o caminho completo, ex.: D:\Programas\V9Flow' 'C' 'unidade'
        if ($r -match '^[A-Za-z]:?$') {
            $letra = $r.Substring(0, 1).ToUpper()
            if ($un.Letra -notcontains $letra) { Write-Host '      Essa unidade nao existe neste computador.'; continue }
            $dest = "${letra}:\V9Flow"
        }
        elseif ($r -match '^[A-Za-z]:\\') { $dest = $r.TrimEnd('\') }
        else { Write-Host '      Digite uma letra, como C ou D, ou o caminho completo.'; continue }
        if ($dest -match '\\Program Files' -or $dest -match '^[A-Za-z]:\\Windows') {
            Write-Host '      Escolha uma pasta fora de Arquivos de Programas e do Windows.'; continue
        }
        try {
            New-Item -ItemType Directory -Path $dest -Force -ErrorAction Stop | Out-Null
            $prova = Join-Path $dest '.escrita'
            Set-Content -Path $prova -Value 'x' -ErrorAction Stop
            Remove-Item $prova -Force
        } catch { Write-Host "      Nao consigo gravar em $dest. Escolha outro lugar."; continue }
        return $dest
    }
}
$Destino = EscolherDestino
Write-Host "      Destino: $Destino"

# ---------- o V9 Flow nao pode estar aberto enquanto os arquivos sao trocados ----------
for ($i = 0; (FlowAberto) -and $i -lt 3; $i++) {
    if ($Teste) { Parar 'Modo de teste: o V9 Flow de teste esta aberto.' }
    Write-Host ''
    Write-Host '      O V9 Flow esta aberto. Feche ele de vez: na tela do V9 Flow, clique em "Sair do V9 Flow".' -ForegroundColor Yellow
    Read-Host '      Depois aperte Enter aqui' | Out-Null
}
if (FlowAberto) { Parar 'O V9 Flow continua aberto. Feche ele ("Sair do V9 Flow") e rode o instalador de novo.' }

# ---------- 1) Python ----------
Passo 1 'Python'
if (PythonOk) { Ok 'Python ja instalado.' }
elseif ($Teste) { Parar 'Modo de teste: instale o Python antes.' }
else {
    if (-not (Tem winget)) {
        Parar ('Este Windows esta sem o "winget". Instale o Python 3.12 em https://www.python.org/downloads/ marcando ' +
               '"Add python.exe to PATH" e rode este instalador de novo.')
    }
    Write-Host '      Instalando o Python 3.12 (so para este usuario)...'
    & winget.exe install --id Python.Python.3.12 -e --scope user --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
    AtualizarPath
    if (-not (PythonOk)) {
        $p = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312'
        if (Test-Path (Join-Path $p 'python.exe')) { $env:Path = "$p;$p\Scripts;$env:Path" }
    }
    if (PythonOk) { Ok 'Python instalado.' } else { Parar 'Nao consegui instalar o Python. Instale em python.org (marque "Add python.exe to PATH") e rode de novo.' }
}

# ---------- 2) login e senha ----------
Passo 2 'Login: este programa e so para membros'
$Tmp = Join-Path $env:TEMP 'v9flowinst'
New-Item -ItemType Directory -Path $Tmp -Force | Out-Null
$Cofre = Join-Path $Tmp 'v9flow_cofre.py'
[IO.File]::WriteAllBytes($Cofre, [Convert]::FromBase64String($CofrePyB64))
$VPy = Join-Path $Tmp 'venv\Scripts\python.exe'
if (-not (Test-Path $VPy)) {
    Write-Host '      Preparando a verificacao de acesso (so na primeira vez)...'
    & python -m venv (Join-Path $Tmp 'venv')
}
& $VPy -c 'import cryptography' 2>$null
if ($LASTEXITCODE -ne 0) { & $VPy -m pip install -q --disable-pip-version-check cryptography 2>&1 | Out-Null }
& $VPy -c 'import cryptography' 2>$null
if ($LASTEXITCODE -ne 0) { Parar 'Nao consegui preparar a verificacao de acesso. Confira a internet e rode de novo.' }

$Membros = Join-Path $Tmp 'membros.json'
try { Invoke-WebRequest -Uri "$BaseUrl/membros.json" -OutFile $Membros -UseBasicParsing -TimeoutSec 30 }
catch { Parar 'Nao consegui buscar a lista de membros. Confira a internet. Se estiver normal, o servidor de distribuicao esta fora do ar: avise o administrador.' }

$OutputEncoding = New-Object System.Text.UTF8Encoding($false)   # login e senha seguem para o Python em UTF-8

Write-Host ''
Write-Host '      TERMO DE USO (resumo)' -ForegroundColor Cyan
Write-Host '      - O acesso e pessoal: um login por pessoa, sem emprestar nem dividir.'
Write-Host '      - E proibido copiar, repassar ou vender o programa ou o codigo.'
Write-Host '      - O administrador pode remover o acesso em caso de uso indevido.'
Write-Host ''
$aceite = Perguntar '      Para aceitar, digite ACEITO e aperte Enter' '' 'termo'
if ("$aceite".Trim().ToUpper() -ne 'ACEITO') { Parar 'O termo de uso nao foi aceito, entao a instalacao foi cancelada.' }

$ChaveDados = $null; $Login = ''
for ($t = 1; $t -le 3 -and -not $ChaveDados; $t++) {
    if ($t -gt 1) { Write-Host '      Login ou senha incorretos. Tente de novo.' -ForegroundColor Yellow }
    $Login = Perguntar '      Login (o que o administrador cadastrou para voce)' '' 'login'
    $senhaMembro = LerSegredo '      Senha' 'senha'
    if (-not $Login -or -not $senhaMembro) { continue }
    $saida = ("$Login`n$senhaMembro`n" | & $VPy $Cofre abrir --membros $Membros)
    $codigo = $LASTEXITCODE
    if ($codigo -eq 0 -and $saida) { $ChaveDados = ($saida | Select-Object -First 1).Trim(); $SenhaLicenca = $senhaMembro }
    $senhaMembro = $null
    if ($codigo -eq 3) { Parar 'A lista de membros veio invalida. Avise o administrador.' }
}
if (-not $ChaveDados) { Parar 'Login ou senha incorretos 3 vezes. Fale com o administrador para cadastrar ou redefinir o seu acesso.' }
Ok "acesso liberado para $Login."

# ---------- 3) baixar o programa ----------
Passo 3 "Baixando o programa para $Destino"
try { $Ultimo = Invoke-RestMethod -Uri "$BaseUrl/latest.json" -TimeoutSec 30 }
catch { Parar 'Nao consegui ver qual e a versao atual. Confira a internet e rode de novo.' }
$VersaoAtual = ''
if (Test-Path (Join-Path $Destino 'VERSAO')) { $VersaoAtual = (Get-Content (Join-Path $Destino 'VERSAO') -Raw).Trim() }
if ((EhDoFlow $Destino) -and $VersaoAtual -eq $Ultimo.versao) {
    Ok "ja esta na versao mais recente ($VersaoAtual)."
} else {
    if ((Test-Path $Destino) -and -not (EhDoFlow $Destino) -and (Get-ChildItem $Destino -Force | Select-Object -First 1)) {
        Parar "A pasta $Destino ja existe e nao e deste programa. Renomeie ou apague essa pasta e rode de novo."
    }
    $Pacote = Join-Path $Tmp $Ultimo.arquivo
    try { Invoke-WebRequest -Uri "$BaseUrl/$($Ultimo.arquivo)" -OutFile $Pacote -UseBasicParsing -TimeoutSec 300 }
    catch { Parar 'Nao consegui baixar o programa. Confira a internet e rode de novo.' }
    $hash = (Get-FileHash $Pacote -Algorithm SHA256).Hash.ToLower()
    if ($hash -ne "$($Ultimo.sha256)".ToLower()) { Parar 'O arquivo baixado esta corrompido (a conferencia falhou). Rode o instalador de novo.' }
    New-Item -ItemType Directory -Path $Destino -Force | Out-Null
    $r = ($ChaveDados + "`n") | & $VPy $Cofre decifrar --pacote $Pacote --destino $Destino
    if ($LASTEXITCODE -eq 4) { Parar 'O seu acesso foi removido ou a chave foi trocada. Fale com o administrador.' }
    if ($LASTEXITCODE -ne 0) { Parar 'Nao consegui abrir o pacote do programa.' }
    [IO.File]::WriteAllText((Join-Path $Destino 'VERSAO'), "$($Ultimo.versao)`n")
    Remove-Item $Pacote -Force -ErrorAction SilentlyContinue
    Ok "programa instalado (versao $($Ultimo.versao))."
}
# a chave do membro fica guardada (protegida pelo Windows): e' com ela que o programa se atualiza sozinho
$ArqChave = Join-Path $Dados 'chave.dpapi'
$null = ($ChaveDados + "`n") | & $VPy $Cofre guardar --destino $ArqChave
if ($LASTEXITCODE -eq 0) { Ok 'acesso guardado neste computador (protegido pelo Windows) para as atualizacoes automaticas.' }
else { Alerta 'Nao consegui guardar o acesso. O programa funciona, mas nao vai se atualizar sozinho: rode este instalador para atualizar.' }
$ChaveDados = $null
Set-Location $Destino
New-Item -ItemType Directory -Path $Dados -Force -ErrorAction SilentlyContinue | Out-Null
[IO.File]::WriteAllText($Lembrete, "$Destino`r`n")        # a proxima vez o instalador ja sabe onde atualizar
[IO.File]::WriteAllText((Join-Path $Destino 'dist_url.txt'), "$BaseUrl`n")
[IO.File]::WriteAllText((Join-Path $Destino 'instalado_para.txt'), "$Login`r`n")    # marca de instalacao: liga a atualizacao automatica

# ---------- 4) ambiente e bibliotecas ----------
Passo 4 'Ambiente proprio do V9 Flow e bibliotecas'
if (-not (Test-Path (Join-Path $Destino 'venv\Scripts\python.exe'))) {
    & python -m venv (Join-Path $Destino 'venv')
}
$AppPy = Join-Path $Destino 'venv\Scripts\python.exe'
if (-not (Test-Path $AppPy)) { Parar 'Nao consegui criar o ambiente do programa (pasta venv). Confira o espaco em disco e rode de novo.' }
& $AppPy (Join-Path $Destino 'abrir.pyw') --preparar
if ($LASTEXITCODE -ne 0) { Parar 'Nao consegui instalar as bibliotecas. Confira a internet e rode de novo.' }
Ok 'bibliotecas prontas.'
# licenca (o mesmo servidor do V9 Vision): ativa ja com o login da instalacao, e o membro aparece no painel na hora
if ($Teste) { Ok 'modo de teste: licenca pulada.' }
else {
    Push-Location $Destino
    $rLic = ("$Login`n$SenhaLicenca`n" | & $AppPy -m v9flow.licenca ativar)
    $codLic = $LASTEXITCODE
    Pop-Location
    if ($codLic -eq 0) { Ok 'licenca ativada neste computador.' }
    else { Alerta ("A licenca nao foi ativada agora: $(($rLic | Select-Object -Last 1)) " +
                   "Ao abrir o V9 Flow, entre com o seu login e senha na tela de entrada.") }
}
$SenhaLicenca = $null

# ---------- 5) atalhos ----------
Passo 5 'Criando os atalhos'
$atalhoMesa = Join-Path ([Environment]::GetFolderPath('Desktop')) "$Nome.lnk"
$atalhoInicio = Join-Path ([Environment]::GetFolderPath('Startup')) "$Nome.lnk"
$pyw = Join-Path $Destino 'venv\Scripts\pythonw.exe'
$abrir = Join-Path $Destino 'abrir.pyw'
$icone = Join-Path $Destino 'v9flow\ui\icone.ico'
if ($Teste) { Ok 'modo de teste: atalhos pulados.' }
else {
    $shell = New-Object -ComObject WScript.Shell
    function Atalho($caminho, $alvo, $argumentos) {
        $a = $shell.CreateShortcut($caminho)
        $a.TargetPath = $alvo
        $a.Arguments = $argumentos
        $a.WorkingDirectory = $Destino
        if (Test-Path $icone) { $a.IconLocation = "$icone,0" }
        $a.Save()
    }
    $menu = Join-Path ([Environment]::GetFolderPath('Programs')) $Nome
    New-Item -ItemType Directory -Path $menu -Force | Out-Null
    Atalho $atalhoMesa $pyw "`"$abrir`""
    Atalho (Join-Path $menu "$Nome.lnk") $pyw "`"$abrir`""
    Atalho (Join-Path $menu "Desinstalar $Nome.lnk") (Join-Path $Destino 'desinstalar.bat') ''
    Ok "atalho `"$Nome`" na Area de Trabalho; desinstalador no Menu Iniciar."
}

# ---------- 6) iniciar com o Windows ----------
Passo 6 'Iniciar com o Windows'
$resp = Perguntar '      Abrir o V9 Flow sozinho (em segundo plano) quando ligar o computador? (S/N, Enter = N)' 'N' 'iniciar'
if ($Teste) { Ok 'modo de teste: inicio automatico pulado.' }
elseif ($resp -match '^[sS]') {
    $shell = New-Object -ComObject WScript.Shell
    $a = $shell.CreateShortcut($atalhoInicio)
    $a.TargetPath = $pyw
    $a.Arguments = "`"$abrir`" --sem-janela"
    $a.WorkingDirectory = $Destino
    if (Test-Path $icone) { $a.IconLocation = "$icone,0" }
    $a.Save()
    Ok 'inicio automatico ligado (sem janela; abre a tela pelo atalho da Area de Trabalho).'
} else {
    Remove-Item -LiteralPath $atalhoInicio -Force -ErrorAction SilentlyContinue
    Ok 'sem inicio automatico.'
}

# ---------- 7) resumo ----------
Passo 7 'Resumo'
$dataAceite = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
[IO.File]::WriteAllText((Join-Path $Destino 'termo_aceito.txt'), "Termo de uso aceito`r`nlogin: $Login`r`ndata: $dataAceite`r`ncomputador: $env:COMPUTERNAME`r`nversao do app: $($Ultimo.versao)`r`n")
if ($Avisos.Count -eq 0) {
    Write-Host '      Tudo certo, nenhuma pendencia.' -ForegroundColor Green
} else {
    Write-Host '      Instalado, com pendencias para resolver:' -ForegroundColor Yellow
    foreach ($a in $Avisos) { Write-Host "       - $a" -ForegroundColor Yellow }
}
Write-Host ''
Write-Host "  Para usar: dois cliques no atalho `"$Nome`" na Area de Trabalho."
Write-Host '  Na primeira vez, clique em "Instalar" (o navegador proprio do V9 Flow, ~200 MB) e entre na sua conta Google.'
Write-Host '  O programa se atualiza sozinho cada vez que voce abre.'
Write-Host ''
if ($Encadeado) { exit 0 }                     # o instalador do V9 Vision continua dali
if (-not $Teste) {
    $abrirAgora = Read-Host '  Abrir o programa agora? (S/N)'
    if ($abrirAgora -match '^[sS]') { Start-Process $atalhoMesa }
}
