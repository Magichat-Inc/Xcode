# Xcode インストール スクリプトと設定手順

[Jamf Nation のスレッド](https://community.jamf.com/t5/jamf-pro/using-jamf-to-deploy-xcode-13-2-1-for-macos-12-3-monterey/td-p/264108)と [YouTube の説明動画](https://www.youtube.com/watch?v=FAqE-KiNJKs)をもとに検証を行いました。

## 手順書

### ① Apple Developer Programから対象[Xcode](https://developer.apple.com/download/all/?q=Xcode)のバージョンをダウンロード

### ② ダウンロードした対象xipファイルを解凍、XcodeアプリをApplicationsフォルダに移動する

### ③ パッケージ化
パッケージ化ツールとして [WhiteBoxのPackagesアプリ](http://s.sudre.free.fr/Software/Packages/about.html) を使用しました。  
（最初は普段使用しているJamf 社のツール Composer を使ってパッケージの作成を試したのですが、失敗するため別ツールを試しました。）
 
<details>
  <summary><i>パッケージ化の手順（クリックして）</i></summary>
  <ul>
    <li>Raw Packageを選択</li>
    <li>プロジェクト名・プロジェクトフォルダを入力</li>
    <li>プロジェクト作成後はSettingsタブに移動</li>
    <li>Options ＞ Require admin password for installationのチェックを外す</li>
    <li>Payloadタブに移動</li>
    <li>Contentsの中にあるApplicationsを選択し、左下の「＋」ボタンを押下</li>
    <li>/Applications/Xcodeを選択</li>
    <li>右横にあるAttributes欄のGroupをwheelに変更(Composerと同様に）</li>
    <li>メニューのFile > Save</li>
    <li>メニューのBuild > Build</li>
    <br>
    <span>Build完了までしばらく待ちます。（Xcode の場合、時間がかかります)</span>
    <br>
    <span>※ Build完了後、プロジェクトフォルダ内にあるbuildフォルダで作成したPKGが表示されます。</span>
  </ul>
</details>

### ④ 作成したPKGをJamf Pro環境にアップロードする
ネット状況にも応じますが、これも結構時間がかかります。

### ⑤ スクリプトの作成
記事に[掲載されていたスクリプト](https://community.jamf.com/t5/jamf-pro/using-jamf-to-deploy-xcode-13-2-1-for-macos-12-3-monterey/m-p/264108/highlight/true#M242859)を一部変更しています。
- コードでGatekeeper後にあるコードを外し、代わりパッケージインストールと初回実行アイテムに関するコードに変更
- 別途post installスクリプトで最新バージョンCommand Line Toolsをインストール　（[参考コメント](https://community.jamf.com/t5/jamf-pro/using-jamf-to-deploy-xcode-13-2-1-for-macos-12-3-monterey/m-p/273267/highlight/true#M248780)）  
  
作成したスクリプト：  
- XcodeConfiguration.zsh
- XcodePostInstallCommandLineTools.sh
- setSleepTime.zsh (処理中にスリープしないようにするため)

### ⑥ ポリシーの作成
④で作成した PKG ファイルと⑤のスクリプトを用いて Jamf Pro でポリシーを作成します。   
スクリプト＞優先順位は以下のような組み合わせとなります。

<details>
  <summary><i>Policyのトリガーで実施する場合（クリックして）</i></summary>
  <ul>
    <li>setSleepTimeをBefore実行</li>
    <li>XcodeConfigurationをAfter実行</li>
    <li>XcodePostInstallCommandLineToolsをAfter実行</li>
  </ul>
</details> 		

<details>
  <summary><i>Self Serviceで実施する場合（クリックして）</i></summary>
  <ul>
    <li>XcodeConfigurationをAfter実行</li>
    <li>XcodePostInstallCommandLineToolsをAfter実行</li>
  </ul>
</details> 

## ログ
XcodeConfigurationスクリプトのインストールログは以下の階層に保存さる：  
```/Library/Logs/Xcode/XCodeInstall.log```

## 検証結果
・ポリシーの実行には2~3時間かかりましたが、問題なくパッケージのインストールとスクリプトによる展開が実行され、アプリも問題なく開くことができました。

※ 今回 macOS Ventura にて検証を行いましたが、今後のメジャーアップデート時は検証して実装をお願いいたします。  
