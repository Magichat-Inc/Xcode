# Xcode インストール スクリプトと設定手順

[Jamf Nation のスレッド](https://community.jamf.com/t5/jamf-pro/using-jamf-to-deploy-xcode-13-2-1-for-macos-12-3-monterey/td-p/264108)と [YouTube の説明動画](https://www.youtube.com/watch?v=FAqE-KiNJKs)をもとに検証を行いました。

## 手順書

### ① Apple Developer Programから[Xcode](https://developer.apple.com/download/all/?q=Xcode)をダウンロード

### ② ダウンロードした対象xipファイルを解凍、XcodeアプリをApplicationsフォルダに移動する

### ③ パッケージ化
検証で、最初はComposerを使ってPKGの作成を何回も試したところ、いつも失敗で終わりました。  
スレッドで書いてあったパケージ化ツール、[WhiteBoxのPackagesアプリ](http://s.sudre.free.fr/Software/Packages/about.html)で成功になりました。  
<details>
  <summary><i>手順（クリックして）</i></summary>
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
    <span>Build完了まで待つ　（Xcodeの場合、時間がかかる)</span>
    <br>
    <span>※ Build完了後、プロジェクトフォルダ内にあるbuildフォルダで作成したPKGが表示される</span>
  </ul>
</details>

### ④ 作成したPKGをJamf Pro環境にアップロードする
ネットの状況によっても関わりますが、これも結構時間がかかる

### ⑤ スクリプトの作成
記事に[掲載されていたスクリプト](https://community.jamf.com/t5/jamf-pro/using-jamf-to-deploy-xcode-13-2-1-for-macos-12-3-monterey/m-p/264108/highlight/true#M242859)を一部変更しています。
- コードでGatekeeper後にあるコードを外し、代わりパッケージインストールと初回実行アイテムに関するコードに変更
- 別途post installスクリプトで最新バージョンCommand Line Toolsをインストール　（[参考コメント](https://community.jamf.com/t5/jamf-pro/using-jamf-to-deploy-xcode-13-2-1-for-macos-12-3-monterey/m-p/273267/highlight/true#M248780)）  
  
作成したスクリプト：  
- XcodeConfiguration.zsh
- XcodePostInstallCommandLineTools.sh
  
処理中にスリープしないようにする処理
- setSleepTime.zsh

### ⑥ ポリシーの作成
④で作成した PKG ファイルと⑤のスクリプトを用いてポリシーを作成
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

## 検証結果
・時間的にはPolicy、Self Serviceは2-3時間かかりましたが問題なく、インストールとスクリプト実行ができ、アプリを開けました。  
・スクリプト自体も大丈夫ですが、メジャーアップデートの時は正常に動くかの確証は必要です。  

## ログ
XcodeConfigurationスクリプトのインストールログは以下の階層に保存さる：  
```/Library/Logs/Xcode/XCodeInstall.log```
