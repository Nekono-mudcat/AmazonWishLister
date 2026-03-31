#Requires AutoHotkey v2.0

; F8キーで実行
F8::
{
    ; 1. コンソールを開く (Brave: Ctrl + Shift + J)
    Send "^+j" 
    Sleep 1200 

    ; 2. JavaScriptコード
    ; AHKの変数を使わず、すべてJSの中で完結させています
    jsCode := "
    (
    (function() {
        let results = [];
        let seenLinks = new Set();
        let items = document.querySelectorAll('.a-list-item, [id^="item_"]');

        items.forEach(item => {
            let text = item.innerText || "";
            if (text.includes('%') || text.includes('％')) {
                let linkEl = item.querySelector('a[id^="itemName"]') || item.querySelector('a.a-link-normal:not(.a-text-normal)');
                if (linkEl) {
                    let title = linkEl.innerText.trim();
                    let href = linkEl.getAttribute('href');
                    if (title && href) {
                        let cleanLink = href.startsWith('http') ? href.split('?')[0] : "https://www.amazon.co.jp" + href.split('?')[0];
                        if (!seenLinks.has(cleanLink)) {
                            results.push(title + '\n' + cleanLink);
                            seenLinks.add(cleanLink);
                        }
                    }
                }
            }
        });

        if (results.length > 0) {
            // JS側で日付を作成
            let now = new Date();
            let dateStr = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0') + '-' + String(now.getDate()).padStart(2, '0');
            let fileName = dateStr + '_amazon_sale.txt';

            let output = results.join('\n\n');
            let blob = new Blob([output], {type: 'text/plain'});
            let a = document.createElement('a');
            a.href = URL.createObjectURL(blob);
            a.download = fileName;
            a.click();
            
            let msg = '完了しました。重複を除いて ' + results.length + ' 件を ' + fileName + ' として保存しました。';
            let alertDiv = document.createElement('div');
            alertDiv.setAttribute('role', 'alert');
            alertDiv.innerText = msg;
            document.body.appendChild(alertDiv);
            alert(msg);
        } else {
            alert("割引商品が見つかりませんでした。");
        }
    })();
    )"

    ; 3. クリップボード経由で貼り付け
    A_Clipboard := jsCode
    if ClipWait(2) {
        Send "^v"
        Sleep 500
        Send "{Enter}"
    }
}

; Escapeキーでスクリプト自体を終了
Esc::
{
    MsgBox "スクリプトを終了しました。", "通知"
    ExitApp
}