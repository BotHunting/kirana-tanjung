function doGet(e) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();

  if (e.parameter.action === 'login') {
    const result = checkLogin(e.parameter.username, e.parameter.password);
    return ContentService.createTextOutput(JSON.stringify(result))
      .setMimeType(ContentService.MimeType.JSON);
  }
  
  // Handler untuk permintaan API JSON dari Flutter/Android
  if (e.parameter.action === 'getData') {
    const data = getAllDataForDashboard();
    return ContentService.createTextOutput(JSON.stringify(data))
      .setMimeType(ContentService.MimeType.JSON);
  }

  if (e.parameter.action === 'updateData') {
    const result = updateDataInSheet(
      e.parameter.sheetName,
      e.parameter.rowIndex,
      e.parameter
    );
    return ContentService.createTextOutput(JSON.stringify(result))
      .setMimeType(ContentService.MimeType.JSON);
  }

  if (e.parameter.action === 'addData') {
    const result = addDataToSheet(e.parameter.sheetName, e.parameter);
    return ContentService.createTextOutput(JSON.stringify(result))
      .setMimeType(ContentService.MimeType.JSON);
  }

  if (e.parameter.action === 'deleteData') {
    const result = deleteDataFromSheet(e.parameter.sheetName, e.parameter.rowIndex);
    return ContentService.createTextOutput(JSON.stringify(result))
      .setMimeType(ContentService.MimeType.JSON);
  }

  if (e.parameter.action === 'kuasa') {
    return HtmlService.createHtmlOutput(getKuasaHtml(
      e.parameter.nama,
      e.parameter.nomor_uji,
      e.parameter.merk_type
    )).setTitle('Surat Kuasa Kirana Tanjung');
  }

  // Ambil data publik untuk tampilan awal
  const template = HtmlService.createTemplateFromFile('index');
  template.publicDesain = getSheetData(ss, "Desain");
  template.publicPercetakan = getSheetData(ss, "Percetakan");
  template.publicBiroJasa = getSheetData(ss, "Biro Jasa");
  template.publicBoutique = getSheetData(ss, "Boutique");

  return template.evaluate()
    .setTitle('CV. KIRANA TANJUNG PELAKAR')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

/**
 * Menangani update status atau data dari aplikasi Android
 */
function doPost(e) {
  try {
    const params = JSON.parse(e.postData.contents);
    if (params.action === 'login') {
      const result = checkLogin(params.username, params.password);
      return ContentService.createTextOutput(JSON.stringify(result))
        .setMimeType(ContentService.MimeType.JSON);
    }
    if (params.action === 'updateStatus') {
      const res = updateDataInSheet(params.sheetName, params.rowIndex, { status: params.newStatus });
      return ContentService.createTextOutput(JSON.stringify(res)).setMimeType(ContentService.MimeType.JSON);
    }
    if (params.action === 'updateData') {
      const res = updateDataInSheet(params.sheetName, params.rowIndex, params.formData || {});
      return ContentService.createTextOutput(JSON.stringify(res)).setMimeType(ContentService.MimeType.JSON);
    }
    return ContentService.createTextOutput(JSON.stringify({ success: false, message: "Action tidak dikenal." }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({success: false, error: err.toString()}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

function checkLogin(username, password) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const userSheet = ss.getSheetByName("Users");
  if (!userSheet) {
    return { success: false, message: "Sheet Users tidak ditemukan." };
  }
  const userData = userSheet.getDataRange().getValues();
  const inputUsername = String(username || '').trim();
  const inputPassword = String(password || '');
  
  for (let i = 1; i < userData.length; i++) {
    if (String(userData[i][0]).trim() === inputUsername && String(userData[i][1]) === inputPassword) {
      return {
        success: true,
        nama: userData[i][2],
        // Kamu bisa kirim data tambahan khusus admin di sini jika perlu
      };
    }
  }
  return { success: false, message: "Akses Ditolak! Cek kembali Username/Password." };
}

function getSheetData(ss, sheetName) {
  const sheet = ss.getSheetByName(sheetName.trim());
  if (!sheet) return [];
  const range = sheet.getDataRange();
  const values = range.getValues();
  if (values.length <= 1) return []; // Hanya header saja
  
  const headers = values.shift();
  // Normalisasi header menjadi key yang bersih (contoh: "No. Whatsapp" -> "no_whatsapp")
  const keys = headers.map(h => h.toString().trim().toLowerCase().replace(/[^a-z0-9]/g, '_').replace(/_+/g, '_').replace(/^_+|_+$/g, ''));

  return values.map((row, idx) => {
    const obj = { row_index: idx + 2 }; // Baris di sheet mulai dari 1, plus header jadi idx + 2
    headers.forEach((header, i) => {
      const key = keys[i];
      let val = row[i];
      if (val instanceof Date) {
        const dateFormat = (key === 'timestamp') ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd";
        val = Utilities.formatDate(val, Session.getScriptTimeZone(), dateFormat);
      }
      obj[key] = (val === undefined || val === null) ? "" : val;
    });
    return obj;
  }).filter(item => {
    // Filter baris yang benar-benar kosong (kecuali row_index)
    return Object.keys(item).some(k => k !== 'row_index' && item[k] !== "");
  });
}
// Fungsi untuk menyimpan data dari Dashboard ke Spreadsheet
function addDataToSheet(sheetName, formData) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName(sheetName);
    if (!sheet) throw new Error("Sheet tidak ditemukan: " + sheetName);

    const headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];
    const keys = headers.map(h => h.toString().trim().toLowerCase().replace(/[^a-z0-9]/g, '_').replace(/_+/g, '_').replace(/^_+|_+$/g, ''));
    const timestamp = new Date();
    
    const rowData = headers.map((header, i) => {
      const key = keys[i];
      if (key === 'timestamp') return timestamp;
      
      const foundKey = Object.keys(formData).find(k => k.toLowerCase().replace(/[^a-z0-9]/g, '_') === key);
      return (foundKey !== undefined && formData[foundKey] !== undefined) ? formData[foundKey] : "";
    });
    
    sheet.appendRow(rowData);
    return { success: true, message: "Data berhasil ditambahkan ke " + sheetName };
  } catch (e) {
    return { success: false, message: e.toString() };
  }
}

function deleteDataFromSheet(sheetName, rowIndex) {
  try {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheetName);
    if (!sheet) throw new Error("Sheet tidak ditemukan: " + sheetName);
    const row = parseInt(rowIndex);
    if (!Number.isInteger(row) || row < 2 || row > sheet.getLastRow()) {
      throw new Error("Nomor baris data tidak valid");
    }
    sheet.deleteRow(row);
    return { success: true, message: "Data berhasil dihapus." };
  } catch (e) {
    console.error(e);
    return { success: false, message: "Gagal menghapus data: " + e.toString() };
  }
}

// Fungsi untuk memperbarui data yang sudah ada
function updateDataInSheet(sheetName, rowIndex, formData) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName(sheetName);
    if (!sheet) throw new Error("Sheet tidak ditemukan");
    const row = parseInt(rowIndex);
    if (!Number.isInteger(row) || row < 2 || row > sheet.getLastRow()) {
      throw new Error("Nomor baris data tidak valid");
    }

    // Mapping kolom sesuai struktur (Kolom 1 adalah Timestamp, jangan diubah)
    let rowData = [];
    if (sheetName.toLowerCase() === "desain") {
      rowData = [[formData.nama, formData.deskripsi, formData.linkgambar, formData.tag, formData.whatsapp, formData.status]];
      sheet.getRange(row, 2, 1, 6).setValues(rowData);
    } else if (sheetName.toLowerCase() === "percetakan") {
      rowData = [[formData.deskripsi, formData.harga, formData.ikon, formData.whatsapp, formData.status]];
      sheet.getRange(row, 2, 1, 5).setValues(rowData);
    } else if (sheetName.toLowerCase() === "biro jasa") {
      rowData = [[formData.layanan, formData.nama, formData.merek, formData.type, formData.nomor_kendaraan, formData.deskripsi, formData.durasi, formData.whatsapp, formData.aktif, formData.foto_stnk]];
      sheet.getRange(row, 2, 1, 10).setValues(rowData);
    } else if (sheetName.toLowerCase() === "boutique") {
      rowData = [[formData.judul, formData.kategori, formData.deskripsi, formData.harga, formData.min_order, formData.gambar_url, formData.status]];
      sheet.getRange(row, 1, 1, 7).setValues(rowData);
    } else {
      throw new Error("Sheet tidak didukung: " + sheetName);
    }

    return { success: true, message: "Data berhasil diperbarui!" };
  } catch (e) {
    console.error(e);
    return { success: false, message: "Gagal memperbarui data: " + e.toString() };
  }
}

// Fungsi untuk menyertakan konten file HTML lain (untuk kerapian)
function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}
// Fungsi untuk mengambil semua data sekaligus untuk Dashboard
function getAllDataForDashboard() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  return {
    desain: getSheetData(ss, "Desain"),
    percetakan: getSheetData(ss, "Percetakan"),
    biroJasa: getSheetData(ss, "Biro Jasa"),
    boutique: getSheetData(ss, "Boutique")
  };
}

// Fungsi untuk memanggil & menyajikan file kuasa.html
function getKuasaHtml(nama, nomorUji, merkType) {
  let html = HtmlService.createHtmlOutputFromFile('kuasa').getContent();
  html = html.replace(
    '<span id="skNamaPemilik" class="font-bold text-slate-900">-</span>',
    '<span id="skNamaPemilik" class="font-bold text-slate-900">' + escapeHtml(nama || '-') + '</span>'
  );
  html = html.replace(
    '<span id="skNoUji" class="font-semibold text-slate-800">-</span>',
    '<span id="skNoUji" class="font-semibold text-slate-800">' + escapeHtml(nomorUji || '-') + '</span>'
  );
  html = html.replace(
    '<span id="skMerkType" class="font-semibold text-slate-800">-</span>',
    '<span id="skMerkType" class="font-semibold text-slate-800">' + escapeHtml(merkType || '-') + '</span>'
  );
  html = html.replace('<span id="skTanggal"></span>', '<span id="skTanggal">' + Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'dd MMMM yyyy') + '</span>');
  return html;
}

function escapeHtml(value) {
  return String(value).replace(/[&<>'"]/g, function(character) {
    return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' })[character];
  });
}