function doGet(e) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  
  // Ambil data publik untuk tampilan awal
  const template = HtmlService.createTemplateFromFile('index');
  template.publicDesain = getSheetData(ss, "Desain");
  template.publicPercetakan = getSheetData(ss, "Percetakan");
  template.publicBiroJasa = getSheetData(ss, "Biro Jasa");

  return template.evaluate()
    .setTitle('CV. KIRANA TANJUNG PELAKAR')
    .addMetaTag('viewport', 'width=device-width, initial-scale=1')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

function checkLogin(username, password) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const userSheet = ss.getSheetByName("Users");
  const userData = userSheet.getDataRange().getValues();
  
  for (let i = 1; i < userData.length; i++) {
    if (userData[i][0] == username && userData[i][1] == password) {
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
    const timestamp = new Date();
    
    let rowData = [];
    if (sheetName === "Desain") {
      rowData = [timestamp, formData.nama, formData.deskripsi, formData.linkgambar, formData.tag, formData.whatsapp, formData.status];
    } else if (sheetName === "Percetakan") {
      rowData = [timestamp, formData.deskripsi, formData.harga, formData.ikon, formData.whatsapp, formData.status];
    } else if (sheetName === "Biro Jasa") {
      rowData = [timestamp, formData.layanan, formData.nama, formData.merek, formData.type, formData.nomor_kendaraan, formData.deskripsi, formData.durasi, formData.whatsapp, formData.aktif, formData.foto_stnk];
    }
    
    sheet.appendRow(rowData);
    return { success: true, message: "Data berhasil ditambahkan ke " + sheetName };
  } catch (e) {
    return { success: false, message: e.toString() };
  }
}

// Fungsi untuk memperbarui data yang sudah ada
function updateDataInSheet(sheetName, rowIndex, formData) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName(sheetName);
    if (!sheet) throw new Error("Sheet tidak ditemukan");
    const row = parseInt(rowIndex);

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
    biroJasa: getSheetData(ss, "Biro Jasa")
  };
}