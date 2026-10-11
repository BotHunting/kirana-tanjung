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
      e.parameter,
      e.parameter.username
    );
    return ContentService.createTextOutput(JSON.stringify(result))
      .setMimeType(ContentService.MimeType.JSON);
  }

  if (e.parameter.action === 'addData') {
    const result = addDataToSheet(e.parameter.sheetName, e.parameter, e.parameter.username);
    return ContentService.createTextOutput(JSON.stringify(result))
      .setMimeType(ContentService.MimeType.JSON);
  }

  if (e.parameter.action === 'deleteData') {
    const result = deleteDataFromSheet(e.parameter.sheetName, e.parameter.rowIndex, e.parameter.username);
    return ContentService.createTextOutput(JSON.stringify(result))
      .setMimeType(ContentService.MimeType.JSON);
  }

  if (e.parameter.action === 'kuasa') {
    return HtmlService.createHtmlOutput(getKuasaHtml(
      e.parameter.nama,
      e.parameter.nomor_uji,
      e.parameter.merk_type,
      e.parameter.penerima_nama,
      e.parameter.penerima_nik,
      e.parameter.penerima_alamat
    )).setTitle('Surat Kuasa Kirana Tanjung');
  }

  // Ambil data publik untuk tampilan awal
  const template = HtmlService.createTemplateFromFile('index');
  template.publicDesain = getSheetData(ss, "Desain");
  template.publicPercetakan = getSheetData(ss, "Percetakan");
  template.publicBoutique = getSheetData(ss, "Boutique");
  template.publicBiroJasa = getSheetData(ss, "Biro Jasa");

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
      const res = updateDataInSheet(params.sheetName, params.rowIndex, { status: params.newStatus }, params.username);
      return ContentService.createTextOutput(JSON.stringify(res)).setMimeType(ContentService.MimeType.JSON);
    }
    if (params.action === 'updateData') {
      const res = updateDataInSheet(params.sheetName, params.rowIndex, params.formData || {}, params.username);
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

  const inputUsername = String(username || '').trim().toLowerCase();
  const inputPassword = String(password || '');

  const cache = CacheService.getScriptCache();
  const lockKey = "lock_" + inputUsername;
  const attemptKey = "attempts_" + inputUsername;

  if (cache.get(lockKey)) {
    return { success: false, message: "Terlalu banyak percobaan gagal. Akun dikunci sementara (5 menit)." };
  }

  const userData = userSheet.getDataRange().getValues();
  const hashedInput = hashPassword(inputPassword);

  for (let i = 1; i < userData.length; i++) {
    const dbUsername = String(userData[i][0]).trim().toLowerCase();
    const dbPassword = String(userData[i][1]).trim();

    if (dbUsername === inputUsername) {
      if (dbPassword === inputPassword || dbPassword === hashedInput) {
        cache.remove(attemptKey);
        return {
          success: true,
          username: userData[i][0], // Tambahkan username ke response
          nama: userData[i][2],
          nik: userData[i][3] || '',
          alamat: userData[i][4] || '',
          role: userData[i][5] || 'user' // Default role jika kosong
        };
      }
    }
  }

  let attempts = parseInt(cache.get(attemptKey) || "0", 10) + 1;
  if (attempts >= 5) {
    cache.put(lockKey, "locked", 300);
    cache.remove(attemptKey);
    return { success: false, message: "Terlalu banyak percobaan gagal. Akun dikunci selama 5 menit." };
  } else {
    cache.put(attemptKey, String(attempts), 600);
  }
  return { success: false, message: "Akses Ditolak! Cek kembali Username/Password." };
}

function hashPassword(password) {
  const digest = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, password, Utilities.Charset.UTF_8);
  return digest.map(function(byte) {
    return ('0' + (byte & 0xFF).toString(16)).slice(-2);
  }).join('');
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
function addDataToSheet(sheetName, formData, username) {
  try {
    // Validate permission
    let permission = '';
    if (sheetName === "Desain") permission = 'canEditDesain';
    else if (sheetName === "Percetakan") permission = 'canEditPrint';
    else if (sheetName === "Boutique") permission = 'canEditBoutique';
    else if (sheetName === "Biro Jasa") permission = 'canEditJasa';

    if (permission) {
      checkPermission(username, permission);
    }

    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = ss.getSheetByName(sheetName);
    if (!sheet) throw new Error("Sheet tidak ditemukan: " + sheetName);
    const timestamp = new Date();

    let rowData = [];
    if (sheetName === "Desain") {
      rowData = [timestamp, formData.nama, formData.deskripsi, formData.linkgambar, formData.tag, formData.whatsapp, formData.status];
    } else if (sheetName === "Percetakan") {
      rowData = [timestamp, formData.deskripsi, formData.harga, formData.ikon, formData.whatsapp, formData.status, formData.keterangan, formData.min_order];
    } else if (sheetName === "Boutique") {
      rowData = [formData.judul, formData.kategori, formData.deskripsi, formData.harga, formData.min_order, formData.gambar_url, formData.status];
    } else if (sheetName === "Biro Jasa") {
      rowData = [timestamp, formData.layanan, formData.nama, formData.merek, formData.type, formData.nomor_kendaraan, formData.deskripsi, formData.durasi, formData.whatsapp, formData.aktif, formData.foto_stnk, username || ""];
    } else {
      throw new Error("Sheet tidak didukung: " + sheetName);
    }

    sheet.appendRow(rowData);
    return { success: true, message: "Data berhasil ditambahkan ke " + sheetName };
  } catch (e) {
    console.error("Add data error:", e);
    return { success: false, message: e.toString() };
  }
}

function deleteDataFromSheet(sheetName, rowIndex, username) {
  try {
    // Validate permission - only admin can delete
    checkPermission(username, 'canDeleteData');

    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheetName);
    if (!sheet) throw new Error("Sheet tidak ditemukan: " + sheetName);
    const row = parseInt(rowIndex);
    if (!Number.isInteger(row) || row < 2 || row > sheet.getLastRow()) {
      throw new Error("Nomor baris data tidak valid");
    }
    sheet.deleteRow(row);
    return { success: true, message: "Data berhasil dihapus." };
  } catch (e) {
    console.error("Delete data error:", e);
    return { success: false, message: "Gagal menghapus data: " + e.toString() };
  }
}

// Fungsi untuk memperbarui data yang sudah ada
function updateDataInSheet(sheetName, rowIndex, formData, username) {
  try {
    // Validate permission
    let permission = '';
    if (sheetName.toLowerCase() === "desain") permission = 'canEditDesain';
    else if (sheetName.toLowerCase() === "percetakan") permission = 'canEditPrint';
    else if (sheetName.toLowerCase() === "boutique") permission = 'canEditBoutique';
    else if (sheetName.toLowerCase() === "biro jasa") permission = 'canEditJasa';

    if (permission) {
      checkPermission(username, permission);
    }

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
      rowData = [[formData.deskripsi, formData.harga, formData.ikon, formData.whatsapp, formData.status, formData.keterangan, formData.min_order]];
      sheet.getRange(row, 2, 1, 7).setValues(rowData);
    } else if (sheetName.toLowerCase() === "boutique") {
      rowData = [[formData.judul, formData.kategori, formData.deskripsi, formData.harga, formData.min_order, formData.gambar_url, formData.status]];
      sheet.getRange(row, 1, 1, 7).setValues(rowData);
    } else if (sheetName.toLowerCase() === "biro jasa") {
      rowData = [[formData.layanan, formData.nama, formData.merek, formData.type, formData.nomor_kendaraan, formData.deskripsi, formData.durasi, formData.whatsapp, formData.aktif, formData.foto_stnk, formData.username || ""]];
      sheet.getRange(row, 2, 1, 12).setValues(rowData);
    } else {
      throw new Error("Sheet tidak didukung: " + sheetName);
    }

    return { success: true, message: "Data berhasil diperbarui!" };
  } catch (e) {
    console.error("Update data error:", e);
    return { success: false, message: "Gagal memperbarui data: " + e.toString() };
  }
}

// Fungsi untuk menyertakan konten file HTML lain (untuk kerapian)
function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}
// Fungsi untuk mengambil semua data sekaligus untuk Dashboard
function getAllDataForDashboard(username) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const userRole = getUserRole(username || '');

  let biroJasaData = getSheetData(ss, "Biro Jasa");

  // Filter data for user role - only show their own data based on username column (Kolom L)
  if (userRole === 'user' && username) {
    const inputUsername = String(username).trim().toLowerCase();
    biroJasaData = biroJasaData.filter(item => {
      const itemUsername = String(item.username || '').trim().toLowerCase();
      return itemUsername === inputUsername;
    });
  }

  return {
    desain: getSheetData(ss, "Desain"),
    percetakan: getSheetData(ss, "Percetakan"),
    boutique: getSheetData(ss, "Boutique"),
    biroJasa: biroJasaData,
    users: getSheetData(ss, "Users")
  };
}

// Fungsi untuk memanggil & menyajikan file kuasa.html
function getKuasaHtml(nama, nomorUji, merkType, penerimaNama, penerimaNik, penerimaAlamat) {
  let html = HtmlService.createHtmlOutputFromFile('kuasa').getContent();
  
  // Penggantian aman menggunakan fungsi callback agar terhindar dari manipulasi regex ($&, $1)
  html = html.replace(
    '<span id="skNamaPemilik" class="font-bold text-slate-900">-</span>',
    () => '<span id="skNamaPemilik" class="font-bold text-slate-900">' + escapeHtml(nama || '-') + '</span>'
  );
  html = html.replace(
    '<span id="skNoUji" class="font-semibold text-slate-800">-</span>',
    () => '<span id="skNoUji" class="font-semibold text-slate-800">' + escapeHtml(nomorUji || '-') + '</span>'
  );
  html = html.replace(
    '<span id="skMerkType" class="font-semibold text-slate-800">-</span>',
    () => '<span id="skMerkType" class="font-semibold text-slate-800">' + escapeHtml(merkType || '-') + '</span>'
  );
  html = html.replace(
    '<span id="skTanggal"></span>',
    () => '<span id="skTanggal">' + Utilities.formatDate(new Date(), Session.getScriptTimeZone(), 'dd MMMM yyyy') + '</span>'
  );
  if (penerimaNama) {
    html = html.replace(
      '<span id="skPenerimaNama">MOHAMMAD SYAHRI</span>',
      () => '<span id="skPenerimaNama">' + escapeHtml(penerimaNama) + '</span>'
    );
  }
  if (penerimaNik) {
    html = html.replace(
      '<span id="skPenerimaNik">9203015308670001</span>',
      () => '<span id="skPenerimaNik">' + escapeHtml(penerimaNik) + '</span>'
    );
  }
  if (penerimaAlamat) {
    html = html.replace(
      '<span id="skPenerimaAlamat">Jl. Ky Syahlan 1 No. 7, Ds. Manyarejo, Kec. Manyar, Kab. Gresik</span>',
      () => '<span id="skPenerimaAlamat">' + escapeHtml(penerimaAlamat) + '</span>'
    );
  }
  return html;
}

function escapeHtml(value) {
  return String(value).replace(/[&<>'"]/g, function(character) {
    return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' })[character];
  });
}

// --- Role-Based Access Control (Backend) ---
function getUserRole(username) {
  try {
    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const userSheet = ss.getSheetByName("Users");
    if (!userSheet) return 'user'; // Default role

    const userData = userSheet.getDataRange().getValues();
    const inputUsername = String(username || '').trim().toLowerCase();

    for (let i = 1; i < userData.length; i++) {
      const dbUsername = String(userData[i][0]).trim().toLowerCase();
      if (dbUsername === inputUsername) {
        return (userData[i][5] || 'user').toLowerCase(); // Role di kolom 6 (index 5)
      }
    }

    return 'user'; // Default jika user tidak ditemukan
  } catch (e) {
    console.error("Error getting user role:", e);
    return 'user';
  }
}

function hasPermission(role, permission) {
  const ROLE_PERMISSIONS = {
    admin: {
      canViewAnalytics: true,
      canExportData: true,
      canImportData: true,
      canBroadcastWA: true,
      canEditDesain: true,
      canEditPrint: true,
      canEditBoutique: true,
      canEditJasa: true,
      canDeleteData: true,
      canManageUsers: true
    },
    staff: {
      canViewAnalytics: true,
      canExportData: true,
      canImportData: false,
      canBroadcastWA: true,
      canEditDesain: true,
      canEditPrint: true,
      canEditBoutique: true,
      canEditJasa: true,
      canDeleteData: false,
      canManageUsers: false
    },
    user: {
      canViewAnalytics: false,
      canExportData: false,
      canImportData: false,
      canBroadcastWA: false,
      canEditDesain: false,
      canEditPrint: false,
      canEditBoutique: false,
      canEditJasa: false,
      canDeleteData: false,
      canManageUsers: false
    }
  };

  return ROLE_PERMISSIONS[role]?.[permission] || false;
}

function checkPermission(username, permission) {
  const role = getUserRole(username);
  if (!hasPermission(role, permission)) {
    throw new Error(`Permission denied. Role '${role}' does not have permission '${permission}'.`);
  }
  return true;
}

// --- Fungsi Import Data dari CSV ---
function importDataFromCSV(category, importData, username) {
  try {
    // Validate permission - only admin can import
    checkPermission(username, 'canImportData');

    const ss = SpreadsheetApp.getActiveSpreadsheet();
    let sheetName = '';

    if (category === 'Desain') sheetName = 'Desain';
    else if (category === 'Percetakan') sheetName = 'Percetakan';
    else if (category === 'Boutique') sheetName = 'Boutique';
    else if (category === 'Biro Jasa') sheetName = 'Biro Jasa';
    else return { success: false, message: 'Kategori tidak valid' };

    const sheet = ss.getSheetByName(sheetName);
    if (!sheet) return { success: false, message: 'Sheet tidak ditemukan: ' + sheetName };

    // Map CSV headers to sheet columns
    const headerMap = {
      'Desain': {
        'Project': 'nama',
        'Tag': 'tag',
        'Deskripsi': 'deskripsi',
        'Status': 'status',
        'WhatsApp': 'whatsapp'
      },
      'Percetakan': {
        'Produk': 'deskripsi',
        'Harga': 'harga',
        'Min. Order': 'min_order',
        'Ikon': 'ikon',
        'Status': 'status',
        'Keterangan': 'keterangan',
        'WhatsApp': 'whatsapp'
      },
      'Boutique': {
        'Judul': 'judul',
        'Kategori': 'kategori',
        'Deskripsi': 'deskripsi',
        'Harga': 'harga',
        'Min. Order': 'min_order',
        'Status': 'status',
        'Gambar URL': 'gambar_url'
      },
      'Biro Jasa': {
        'Layanan': 'layanan',
        'Nama': 'nama',
        'Merek': 'merek',
        'Type': 'type',
        'No. Kendaraan': 'nomor_kendaraan',
        'Deskripsi': 'deskripsi',
        'Progres': 'durasi',
        'Masa Aktif': 'aktif',
        'Status': 'status',
        'STNK': 'foto_stnk',
        'WhatsApp': 'whatsapp',
        'Username': 'username'
      }
    };

    const map = headerMap[category];
    const timestamp = new Date();
    let successCount = 0;
    let errorCount = 0;

    importData.forEach(row => {
      try {
        let rowData = [];

        if (category === 'Desain') {
          rowData = [
            timestamp,
            row['Project'] || '',
            row['Deskripsi'] || '',
            '', // linkgambar (default empty)
            row['Tag'] || '',
            row['WhatsApp'] || '',
            row['Status'] || 'ON PROCESS'
          ];
        } else if (category === 'Percetakan') {
          rowData = [
            timestamp,
            row['Produk'] || '',
            row['Harga'] || '',
            row['Ikon'] || '',
            row['WhatsApp'] || '',
            row['Status'] || 'ON PROCESS',
            row['Keterangan'] || '',
            row['Min. Order'] || '1 Pcs'
          ];
        } else if (category === 'Boutique') {
          rowData = [
            row['Judul'] || '',
            row['Kategori'] || 'BOUTIQUE',
            row['Deskripsi'] || '',
            row['Harga'] || '',
            row['Min. Order'] || '1 Pcs',
            row['Gambar URL'] || '',
            row['Status'] || 'AKTIF'
          ];
        } else if (category === 'Biro Jasa') {
          rowData = [
            timestamp,
            row['Layanan'] || '',
            row['Nama'] || '',
            row['Merek'] || '',
            row['Type'] || '',
            row['No. Kendaraan'] || '',
            row['Deskripsi'] || '',
            row['Progres'] || 'Proses',
            row['WhatsApp'] || '',
            row['Masa Aktif'] || '',
            row['STNK'] || '',
            row['Username'] || username // Use the logged-in username
          ];
        }

        sheet.appendRow(rowData);
        successCount++;
      } catch (e) {
        console.error('Error importing row:', e);
        errorCount++;
      }
    });

    const message = errorCount > 0
      ? `${successCount} data berhasil diimport, ${errorCount} gagal ke ${sheetName}`
      : `${successCount} data berhasil diimport ke ${sheetName}`;

    return { success: true, message: message };
  } catch (e) {
    console.error('Import error:', e);
    return { success: false, message: 'Gagal import: ' + e.toString() };
  }
}

// --- Fungsi Update Role User ---
function updateUserRole(username, newRole, requestUsername) {
  try {
    // Validate permission - only admin can manage users
    checkPermission(requestUsername, 'canManageUsers');

    // Prevent admin from changing their own role
    if (username.toLowerCase() === requestUsername.toLowerCase()) {
      return { success: false, message: "Anda tidak dapat mengubah role sendiri." };
    }

    const ss = SpreadsheetApp.getActiveSpreadsheet();
    const userSheet = ss.getSheetByName("Users");
    if (!userSheet) return { success: false, message: "Sheet Users tidak ditemukan." };

    const userData = userSheet.getDataRange().getValues();
    let rowIndex = -1;

    for (let i = 1; i < userData.length; i++) {
      const dbUsername = String(userData[i][0]).trim().toLowerCase();
      if (dbUsername === username.toLowerCase()) {
        rowIndex = i + 1; // Row index di sheet (1-based)
        break;
      }
    }

    if (rowIndex === -1) {
      return { success: false, message: "User tidak ditemukan." };
    }

    // Update role di kolom 6 (index 5)
    userSheet.getRange(rowIndex, 6).setValue(newRole);

    return { success: true, message: "Role user berhasil diperbarui." };
  } catch (e) {
    console.error("Update role error:", e);
    return { success: false, message: "Gagal update role: " + e.toString() };
  }
}

// --- Fungsi WhatsApp Broadcast ---
function sendWABroadcast(messages, username) {
  try {
    // Validate permission - admin and staff can broadcast
    checkPermission(username, 'canBroadcastWA');

    // Konfigurasi WhatsApp Business API (Meta)
    // Anda perlu setup di Meta Business Suite: https://business.facebook.com/

    // Ganti dengan credentials WhatsApp Business API Anda
    const ACCESS_TOKEN = 'YOUR_WHATSAPP_ACCESS_TOKEN'; // Dari Meta Business Suite
    const PHONE_NUMBER_ID = 'YOUR_PHONE_NUMBER_ID'; // Dari Meta Business Suite
    const API_VERSION = 'v18.0'; // Gunakan versi terbaru

    let successCount = 0;
    let failCount = 0;
    const results = [];

    messages.forEach((msg, index) => {
      try {
        // Format nomor WhatsApp dari sheet (8xxx) ke format internasional (628xxx)
        let phone = msg.phone.toString().trim();

        // Hapus semua karakter non-digit
        phone = phone.replace(/\D/g, '');

        // Konversi format:
        // 8xxx -> 628xxx
        // 08xxx -> 628xxx
        // 628xxx -> 628xxx (sudah benar)
        if (phone.startsWith('8')) {
          phone = '62' + phone;
        } else if (phone.startsWith('08')) {
          phone = '62' + phone.substring(1);
        } else if (phone.startsWith('0')) {
          phone = '62' + phone.substring(1);
        }

        // Pastikan format 62xxx
        if (!phone.startsWith('62')) {
          phone = '62' + phone;
        }

        // Payload untuk WhatsApp Business API
        const payload = {
          messaging_product: 'whatsapp',
          to: phone,
          type: 'text',
          text: {
            body: msg.message
          }
        };

        const apiUrl = `https://graph.facebook.com/${API_VERSION}/${PHONE_NUMBER_ID}/messages`;

        const response = UrlFetchApp.fetch(apiUrl, {
          method: 'post',
          contentType: 'application/json',
          payload: JSON.stringify(payload),
          headers: {
            'Authorization': `Bearer ${ACCESS_TOKEN}`
          },
          muteHttpExceptions: true
        });

        const responseCode = response.getResponseCode();
        const responseBody = response.getContentText();

        if (responseCode === 200 || responseCode === 201) {
          const result = JSON.parse(responseBody);
          successCount++;
          results.push({
            phone: phone,
            status: 'success',
            messageId: result.messages?.[0]?.id || 'N/A'
          });
        } else {
          failCount++;
          let errorMessage = 'Unknown error';
          try {
            const errorData = JSON.parse(responseBody);
            errorMessage = errorData.error?.message || responseBody;
          } catch (e) {
            errorMessage = responseBody;
          }
          results.push({
            phone: phone,
            status: 'failed',
            error: errorMessage,
            responseCode: responseCode
          });
          console.error(`Failed to send to ${phone}: ${errorMessage}`);
        }

      } catch (e) {
        console.error(`Error sending to ${msg.phone}:`, e);
        failCount++;
        results.push({
          phone: msg.phone,
          status: 'error',
          error: e.toString()
        });
      }

      // Rate limiting: tunggu 1 detik antar pesan untuk menghindari rate limit
      // WhatsApp Business API limit: ~50 messages per second untuk production
      Utilities.sleep(1000);
    });

    return {
      success: true,
      message: `Broadcast selesai: ${successCount} berhasil, ${failCount} gagal`,
      results: results
    };
  } catch (e) {
    console.error('Broadcast error:', e);
    return {
      success: false,
      message: 'Gagal broadcast: ' + e.toString(),
      results: []
    };
  }
}