---
layout: post
title:  "MAC에 zsh 설치하기"
date:   2020-12-22 12:36:12 +0900
categories: Mac
tags: [zsh, mac, iterm2]
---

개발하기 편하게 iTerm2와 zsh을 설치하고 설정 합니다.



## iTrem2 설치 하기

화면 분할과 탭으로 터미널을 만들 수 있어 편하게 사용할 수 있습니다.
```
brew cask install iterm2
```
> brew가 설치 안된 경우는 `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`로 설치 합니다.



## zsh 설치 하기

Mac의 기본 쉘인 bash를 대체하여, 각종 플러그인으로 개발 환경을 구성합니다.
brew로 설치하고 기본쉘을 zsh로 대체 합니다.
```
brew install zsh zsh-completions

chsh -s $(which zsh)
```



## oh-my-zsh 설치

플러그인 테마를 관리해 줍니다.

```
brew install curl

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```



## oh-my-zsh의 플러그인 설치

1. zsh-syntax-highlighting
명령어 하이라이팅 플러그인
```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

2. zsh-autosuggestions
자동완성 플러그인
```
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

3. zsh 설정파일에 플러그인 추가
`~/.zshrc` 파일에서 plugins를 찾아서 zsh-syntax-highlighting과 zsh-autosuggestions를 추가해 줍니다.
```
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)
```

4. 저장한 설정 파일 적용
```
source ~/.zshrc
```



## Shell Prompt 변경

1. Powerlevel10k
```
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
```

2. zsh 설정파일에 테마 수정
`~/.zshrc` 파일에서 `ZSH_THEME="robbyrussell"`를 찾아서 변경
```
ZSH_THEME="powerlevel10k/powerlevel10k"
```

> 재설정이 필요하면 `p10k configure`를 입력한다.



### (자동 설치) Visual Studio Code 에서 폰트가 깨지면 `MesloLGS NF` 폰트를 설치 한다.

#### 아래 처름 다이아몬드가 깨짐.
```
    This is Powerlevel10k configuration wizard. It will ask you a few questions and
                                 configure your prompt.

                    Does this look like a diamond (rotated square)?
                      reference: https://graphemica.com/%E2%97%86

                                     --->    <---

(y)  Yes.
(n)  No.
(q)  Quit and do nothing.

Choice [ynq]: 
```

#### 설치

[powerlevel10k에서 font 설치 참고](https://github.com/romkatv/powerlevel10k/#meslo-nerd-font-patched-for-powerlevel10k) 하여 폰트 다운로드하고 사용하는 터미널에 맞게 설정 하면 됩니다.

* 폰트 다운로드
  - MesloLGS NF Regular.ttf
  - MesloLGS NF Bold.ttf
  - MesloLGS NF Italic.ttf
  - MesloLGS NF Bold Italic.ttf

> 다운로드 받은 폰트를 더블 클릭하여 '서체설치' 버튼을 클릭한다.

* Visual Studio Code: Open Code → Preferences → Settings, enter terminal.integrated.fontFamily in the search box and set the value to MesloLGS NF




## 참고
[본격 macOS에 개발 환경 구축하기](https://subicura.com/2017/11/22/mac-os-development-environment-setup.html)
> subicura 님의 개발 환경 구축하기 강력 추천 합니다. 방대한 설정을 다루고 있어서 본인에 맞게 설정하고 설치하여 사용하면 됩니다. 