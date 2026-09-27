-- Unit: 모듈 시스템 (Unit ID: 126)
-- Chapter: Node.js (Chapter ID: 11)

-- Lesson 생성
INSERT INTO lesson (id, unit_id, title)
VALUES (552, 126, '모듈 형식 판별과 트리 셰이킹'),
       (710, 126, '모듈 래퍼와 조건부 exports 해석'),
       (868, 126, '순환 참조와 라이브 바인딩, 지연 로딩');

-- =====================================================
-- Lesson 552: 모듈 형식 판별과 트리 셰이킹
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (3491, 552, '아래 app.js를 실행했을 때 콘솔에 출력되는 값은?', '```javascript
// counter.js
let count = 0;
function increment() { count++; }
module.exports = { count, increment };
```

```javascript
// app.js
const a = require(''./counter'');
a.increment();
const b = require(''./counter'');
console.log(a === b, a.count);
```', 'OBJECTIVE'),
       (3492, 552, '아래 모듈 시스템에 대한 설명으로 옳은 것은?', '이 모듈 시스템은 의존 모듈 선언을 파일 최상단에 문자열 경로로만 둘 수 있게 하고, 코드를 실행하기 전에 파싱 → 링킹 → 평가 세 단계를 거쳐 의존 그래프를 확정한다.', 'OBJECTIVE'),
       (3493, 552, '아래 프로젝트에서 Node.js가 CommonJS로 해석하는 파일을 모두 고른 것은?', '```
myapp/
├─ package.json        → { "name": "myapp", "type": "module" }
├─ server.js
├─ legacy.cjs
├─ scripts/
│  └─ report.mjs
└─ tools/
   ├─ package.json     → { "name": "myapp-tools", "type": "commonjs" }
   ├─ build.js
   └─ check.mjs
```', 'OBJECTIVE'),
       (3494, 552, '아래 비교표를 바탕으로 판단한 내용으로 옳지 않은 것은?', '| 항목 | CommonJS | ESM |
|---|---|---|
| 로딩 방식 | 동기. 실행 도중 함수·조건문 안에서도 호출 가능 | 비동기. 파싱 → 링킹 → 평가 3단계 |
| 순환 참조 | 아직 다 채워지지 않은 내보내기 객체를 받음 | 링킹 때 바인딩을 연결하고, 초기화 전에 읽으면 TDZ 오류 |
| 최상위 await | 불가 | 가능 |
| 파일 경로 정보 | `__filename`, `__dirname` | `import.meta.url` |', 'OBJECTIVE'),
       (3495, 552, '아래 after.js의 ???에 들어갈, Promise를 반환하는 호출 표현식의 이름은?', 'Node.js 20.10에서 돌아가는 프로젝트다. package.json에 `type` 필드가 없고, 의존성으로 chalk 5.x가 설치되어 있다.

```javascript
// before.js — 실행하자마자 오류를 내며 종료된다
const chalk = require(''chalk'');
console.log(chalk.green(''ok''));
```

```javascript
// after.js — 같은 환경에서 ok가 정상 출력된다
async function main() {
  const { default: chalk } = await ???(''chalk'');
  console.log(chalk.green(''ok''));
}
main();
```', 'SUBJECTIVE'),
       (3496, 552, '아래에서 번들 크기가 줄어든 이유가 된 최적화 기법의 이름은?', '사내 유틸 패키지는 함수 32개를 내보내고, 어떤 화면은 그중 2개만 가져다 쓴다. 이 화면을 번들러로 빌드하면 결과물이 420KB였다.

패키지의 빌드 출력물을 `require` / `module.exports` 형태에서 `import` / `export` 선언 형태로만 바꾸고 다시 빌드하자, 같은 화면의 번들이 96KB로 줄었다. 화면 코드와 로직은 한 줄도 고치지 않았다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 3491
(9483, 3491, '`false 0`', 'require를 부를 때마다 파일을 다시 실행해 새 객체를 만든다고 본 오개념. 한 번 읽은 모듈은 require.cache에 담겨 이후 호출에서 같은 객체가 그대로 돌아오므로 a와 b는 같은 객체다.', false),
(9484, 3491, '`true 0`', '같은 경로의 모듈은 캐시에서 같은 객체로 돌아와 a === b가 참이다. module.exports에 담긴 count는 내보내던 순간의 값 0이 복사된 것이라, increment()로 모듈 안의 변수가 1이 되어도 a.count는 0에 머문다.', true),
(9485, 3491, '`true 1`', 'ESM의 라이브 바인딩을 CommonJS에 그대로 적용한 오개념. { count, increment }는 변수의 참조가 아니라 그 시점의 값을 복사해 담으므로 이후 내부 변수가 변해도 가져간 쪽에는 보이지 않는다.', false),
(9486, 3491, '`false 1`', '모듈이 호출마다 새로 실행된다고 보면서 내부 변수 변화까지 반영된다고 본 것. 캐시와 값 복사라는 두 특성을 한꺼번에 뒤집은 결과다.', false),

-- 문제 3492
(9487, 3492, '선언 없이 변수에 값을 대입해도 오류 없이 새 전역 변수가 만들어진다.', '값 복사 방식 모듈의 느슨한 실행 환경을 갖다 붙인 오개념. 이 시스템의 모듈은 언제나 엄격 모드로 평가되므로 선언 없는 대입은 ReferenceError로 막힌다.', false),
(9488, 3492, '모듈 최상단의 this는 그 파일이 내보낼 객체를 가리킨다.', 'this로 내보내기 객체에 접근하던 습관에서 오는 오개념. 여기서는 내보내기가 선언으로 확정되므로 모듈 최상단의 this는 어떤 객체도 가리키지 않고 undefined다.', false),
(9489, 3492, '같은 모듈을 여러 파일에서 가져오면 파일마다 본문이 다시 평가된다.', '가져오기 횟수만큼 실행된다고 본 오개념. 의존 그래프에서 같은 경로는 한 인스턴스로 묶여 본문 평가는 한 번뿐이고, 이후 가져오는 쪽은 같은 인스턴스를 공유한다.', false),
(9490, 3492, '가져온 이름은 원본 변수가 바뀌면 함께 바뀌지만 가져온 쪽에서 다시 대입할 수는 없다.', '링킹 단계에서 값이 아니라 변수의 참조를 연결하기 때문에 원본이 늘거나 줄면 가져간 쪽에도 그대로 보인다. 다만 이 연결은 읽기 전용이라 가져온 이름에 대입하면 TypeError가 난다.', true),

-- 문제 3493
(9491, 3493, 'legacy.cjs, tools/build.js', '확장자 .cjs는 설정과 무관하게 CommonJS다. tools/build.js는 확장자가 .js라 가장 가까운 package.json을 보는데, tools/package.json의 type이 commonjs이므로 CommonJS로 해석된다.', true),
(9492, 3493, 'legacy.cjs', '판별에 확장자만 쓰인다고 본 오개념. .js 파일은 가장 가까운 package.json의 type 필드를 따르므로 tools/build.js도 CommonJS 쪽으로 넘어간다.', false),
(9493, 3493, 'legacy.cjs, server.js, tools/build.js', '.js는 언제나 CommonJS라는 기본값만 기억한 오개념. 루트 package.json이 type을 module로 선언했으므로 server.js는 ESM으로 해석된다.', false),
(9494, 3493, 'legacy.cjs, tools/build.js, tools/check.mjs', '하위 package.json의 type이 그 디렉터리 전체를 덮는다고 본 오개념. 확장자 .mjs는 어떤 type 값이 위에 있어도 항상 ESM이다.', false),

-- 문제 3494
(9495, 3494, 'CommonJS에서는 환경 변수 값을 확인한 뒤 필요한 어댑터만 함수 안에서 불러오는 코드를 쓸 수 있다.', '참인 진술이다. 로딩이 동기라 호출한 자리에서 읽기·실행·반환이 끝나고, 그래서 최상단이 아닌 실행 흐름 중간에서도 불러올 수 있다.', false),
(9496, 3494, 'ESM 파일에서 경로를 조립하려고 `__dirname`을 그대로 쓰면 정의되지 않은 식별자라 실행이 멈춘다.', '참인 진술이다. ESM에는 그 식별자가 없고 `import.meta.url`이 대신 제공되므로, 디렉터리 경로가 필요하면 이 URL을 경로로 바꿔 써야 한다.', false),
(9497, 3494, 'ESM은 평가 전에 링킹을 끝내므로 순환 참조 구조에서 어느 쪽을 먼저 실행하든 항상 초기화된 값을 읽는다.', '표의 순환 참조 칸에 정면으로 걸리는 거짓 진술이다. 링킹은 바인딩을 미리 이어 둘 뿐 값을 채우지는 않아, 아직 평가되지 않은 변수를 읽으면 TDZ 오류가 난다.', true),
(9498, 3494, '설정 파일을 비동기로 읽어 그 결과로 초기화하는 코드를 ESM에서는 함수로 감싸지 않고 모듈 최상단에 둘 수 있다.', '참인 진술이다. 평가 단계 자체가 비동기라 최상위 await가 허용되고, 그 모듈을 가져가는 쪽은 초기화가 끝난 뒤에 평가된다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1120, 3495, '동적 import,동적 import(),동적 임포트,다이나믹 import,dynamic import,dynamic import(),import()', 'chalk 5.x는 ESM 전용 패키지인데 이 프로젝트는 `type` 필드가 없어 CommonJS로 해석되므로, before.js의 require는 ERR_REQUIRE_ESM으로 막힌다. 동적 import()는 선언이 아니라 Promise를 반환하는 호출 표현식이라 CommonJS 파일 안에서도 쓸 수 있고, 결과가 모듈 네임스페이스 객체라 default를 꺼내 써야 한다. 최상단에 두는 정적 import 선언은 ESM 파일에서만 쓸 수 있다는 점과 구분한다. Node 22.12 / 20.19 이상에서는 최상위 await가 없는 ESM에 한해 require로도 동기 로드가 가능하지만, 위 버전은 그보다 낮다.'),
       (1121, 3496, '트리 셰이킹,트리셰이킹,트리 쉐이킹,tree shaking,tree-shaking,treeshaking', '가져오는 이름이 실행 전에 확정되는 `import` / `export` 선언 덕분에, 번들러가 어떤 내보내기가 실제로 쓰이는지 정적으로 판별해 나머지 30개를 결과물에서 뺀 것이다. `require`는 실행 시점에 경로와 이름을 정할 수 있어 이 판별이 어렵고, 그래서 같은 코드라도 CommonJS 출력물에서는 크기가 잘 줄지 않는다. 진입점을 나눠 필요한 순간에 따로 내려받게 하는 코드 스플리팅과는 목적이 다르다. 트리 셰이킹은 쓰지 않는 코드를 결과물에서 없애고, 코드 스플리팅은 내려받는 시점을 미룬다.');

-- =====================================================
-- Lesson 710: 모듈 래퍼와 조건부 exports 해석
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (4439, 710, '아래 app.cjs를 실행했을 때 콘솔에 출력되는 결과는?', '```javascript
// config.cjs
exports.retries = 3;
exports = { host: ''localhost'' };
exports.debug = true;
```

```javascript
// app.cjs
const config = require(''./config.cjs'');
console.log(config.retries, config.host, config.debug);
```', 'OBJECTIVE'),
       (4440, 710, '아래 app.mjs가 오류 없이 실행되게 하는 text-utils.cjs의 내보내기 줄은?', '```javascript
// text-utils.cjs
function slugify(s) {
  return s.toLowerCase().replace(/\s+/g, ''-'');
}
const helpers = { slugify };
// ← 이 자리에 내보내기 줄 하나를 넣는다
```

```javascript
// app.mjs
import { slugify } from ''./text-utils.cjs'';
console.log(slugify(''Hello World''));
```', 'OBJECTIVE'),
       (4441, 710, '아래 표의 실행 가운데 예외 없이 모듈을 불러오는 것만 모두 고른 것은?', '`main.cjs`(CommonJS 파일)에서 같은 폴더의 ESM 파일을 불러오는 코드를 Node.js 버전별로 실행했다.

| 실행 | Node.js 버전 | main.cjs의 불러오기 코드 | 대상 파일의 특징 |
|---|---|---|---|
| A | 20.10 | `require(''./sync.mjs'')` | 최상위 await 없음 |
| B | 22.12 | `require(''./sync.mjs'')` | 최상위 await 없음 |
| C | 22.12 | `require(''./tla.mjs'')` | 최상위 await 있음 |
| D | 20.10 | async 함수 안에서 `await import(''./tla.mjs'')` | 최상위 await 있음 |', 'OBJECTIVE'),
       (4442, 710, '아래 세 파일이 불러오게 되는 date-kit의 실제 파일을 바르게 짝지은 것은?', '`node_modules/date-kit/package.json`의 내용은 다음과 같고, `dist/index.mjs`와 `dist/index.cjs`는 둘 다 `format` 함수를 내보낸다.

```json
{
  "name": "date-kit",
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.cjs"
    }
  }
}
```

```javascript
// report.cjs
const { format } = require(''date-kit'');

// view.mjs
import { format } from ''date-kit'';

// loader.cjs
async function load() {
  const { format } = await import(''date-kit'');
  return format;
}
```', 'OBJECTIVE'),
       (4443, 710, '아래 실행 결과를 한꺼번에 설명하는, Node.js가 CommonJS 파일에 적용하는 장치의 이름은?', '`probe.cjs`를 아래처럼 작성하고 두 가지 방법으로 실행했다.

```javascript
// probe.cjs
var secret = 42;
console.log(arguments.length);
console.log(this === module.exports);
console.log(globalThis.secret);
if (process.env.SKIP) return;
console.log(''end'');
```

```
$ node probe.cjs
5
true
undefined
end

$ SKIP=1 node probe.cjs
5
true
undefined
```

두 번째 실행에서 파일 최상단의 `return`은 SyntaxError 없이 그 아래 줄만 건너뛰었다.', 'SUBJECTIVE'),
       (4444, 710, '확장자를 바꾼 뒤 아래 증상을 일으킨 JavaScript 실행 모드의 이름은?', 'package.json에 `type` 필드가 없는 프로젝트에서 잘 돌던 `legacy.js`를, 코드는 그대로 두고 확장자만 `legacy.mjs`로 바꿨다.

```javascript
// legacy.mjs
function whoAmI() {
  return this;
}
console.log(whoAmI() === globalThis);

const FILE_MODE = 0644;
console.log(FILE_MODE);
```

- `legacy.js`로 실행할 때: `true`, `420`이 차례로 출력됐다.
- `legacy.mjs`로 실행할 때: 아무것도 출력되지 않고 `const FILE_MODE = 0644;` 위치를 가리키는 SyntaxError로 로드가 실패했다.
- `0644`를 `0o644`로 고친 뒤: `false`, `420`이 출력됐고, `whoAmI()`는 `undefined`를 돌려줬다.', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 4439
(12011, 4439, '`3 localhost true`', '재할당한 뒤에도 exports가 내보낼 객체와 계속 이어져 새 속성이 합쳐진다고 본 오개념. exports는 module.exports를 가리키던 지역 변수일 뿐이라 재할당하는 순간 연결이 끊기고, host·debug는 require가 돌려주지 않는 새 객체에 붙는다.', false),
(12012, 4439, '`undefined localhost true`', '객체를 exports에 대입하면 내보낼 객체가 통째로 바뀐다고 본 오개념. require가 돌려주는 것은 언제나 module.exports이고 exports 재할당은 지역 변수만 바꾸므로, 첫 줄에서 붙인 retries만 남는다.', false),
(12013, 4439, '`3 undefined undefined`', '첫 줄은 module.exports를 가리키는 exports에 retries를 붙여 실제로 내보낸다. 둘째 줄은 exports라는 지역 변수가 새 객체를 가리키게 할 뿐이라, 그 객체와 셋째 줄에서 붙인 debug는 require 결과에 들어가지 않는다.', true),
(12014, 4439, '`3 undefined true`', '재할당 줄만 효과가 없고 exports는 여전히 module.exports를 가리킨다고 본 오개념. 대입 자체는 실행돼 exports가 host를 가진 새 객체로 바뀌므로, 셋째 줄의 debug도 그 새 객체에 붙어 내보내지지 않는다.', false),

-- 문제 4440
(12015, 4440, '`Object.assign(module.exports, helpers);`', '실행 결과 module.exports에 slugify가 담기니 이름으로도 가져올 수 있다고 본 오개념. Node.js는 CommonJS 소스를 실행하지 않고 문법 패턴만 훑어 내보내는 이름을 찾으므로, 함수 호출로 붙인 속성은 드러나지 않아 Named export not found 오류가 난다.', false),
(12016, 4440, '`exports.slugify = slugify;`', 'exports.이름 = 값 꼴은 소스를 훑기만 해도 내보내는 이름이 드러나, Node.js가 slugify를 명명 내보내기로 인식한다. 그래서 ESM 쪽의 { slugify } 가져오기가 링킹 단계에서 그대로 연결된다.', true),
(12017, 4440, '`module.exports = helpers;`', 'module.exports에 객체를 대입했으니 그 속성이 모두 이름으로 잡힌다고 본 오개념. 대입한 것이 변수 이름뿐이라 소스만으로는 안에 어떤 속성이 있는지 알 수 없다. 이런 경우엔 default로 받아 구조 분해해야 한다.', false),
(12018, 4440, '`for (const k in helpers) exports[k] = helpers[k];`', 'exports에 직접 속성을 붙이니 exports.이름 = 값 꼴과 같다고 본 오개념. 붙일 이름이 실행 중에 k로 정해져 소스에는 slugify라는 이름이 나타나지 않으므로 명명 가져오기가 실패한다.', false),

-- 문제 4441
(12019, 4441, 'D', 'require로는 ESM을 절대 불러올 수 없다고 본 오개념. Node.js 22.12·20.19 이상은 최상위 await가 없는 ESM에 한해 require로도 동기 로드하므로 B는 성공한다. A는 20.10이라 ERR_REQUIRE_ESM이 난다.', false),
(12020, 4441, 'B', 'import()가 ESM 파일에서만 쓸 수 있는 문법이라고 본 오개념. import()는 Promise를 돌려주는 호출 표현식이라 CommonJS 파일에서도 쓸 수 있고, 평가를 비동기로 기다리므로 최상위 await가 있는 대상도 불러온다.', false),
(12021, 4441, 'B, C, D', 'require가 최상위 await가 끝날 때까지 기다려 준다고 본 오개념. require는 호출한 자리에서 결과를 동기로 돌려줘야 해서, 비동기 평가가 필요한 모듈 그래프를 만나면 ERR_REQUIRE_ASYNC_MODULE로 멈춘다.', false),
(12022, 4441, 'B, D', 'B는 22.12의 require가 최상위 await 없는 ESM을 동기로 불러와 성공한다. C는 대상의 최상위 await 때문에 동기 반환이 불가능해 오류가 나고, D는 Promise를 기다리는 import()라 20.10에서도 성공한다. A는 ERR_REQUIRE_ESM이다.', true),

-- 문제 4442
(12023, 4442, 'report.cjs → index.cjs, view.mjs → index.mjs, loader.cjs → index.mjs', 'exports의 조건은 부르는 파일의 종류가 아니라 불러오는 방식으로 고른다. require 호출은 require 조건, import 선언과 import() 호출은 import 조건에 맞춰지므로 CommonJS 파일인 loader.cjs도 index.mjs를 받는다.', true),
(12024, 4442, 'report.cjs → index.cjs, view.mjs → index.mjs, loader.cjs → index.cjs', '호출하는 파일이 CommonJS면 require 조건을 탄다고 본 오개념. 조건은 파일 종류가 아니라 불러오는 문법으로 정해지며, loader.cjs의 import()는 import 조건으로 해석돼 index.mjs를 받는다.', false),
(12025, 4442, 'report.cjs → index.cjs, view.mjs → index.cjs, loader.cjs → index.cjs', 'date-kit의 package.json에 type 필드가 없으니 패키지 전체가 CommonJS 쪽 진입점만 쓴다고 본 오개념. exports 조건이 불러오는 방식별 진입점을 먼저 정하고, .mjs 확장자 파일은 type과 무관하게 ESM이다.', false),
(12026, 4442, 'report.cjs → index.mjs, view.mjs → index.mjs, loader.cjs → index.mjs', 'import 조건이 먼저 적혀 있으니 모든 호출이 그 경로를 받는다고 본 오개념. 조건은 적힌 순서대로 보되 현재 불러오기 방식과 맞는 것만 고르므로, require 호출에는 import 조건이 맞지 않아 index.cjs로 간다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1436, 4443, '모듈 래퍼,모듈래퍼,모듈 래퍼 함수,module wrapper,module wrapper function,wrapper function,래퍼 함수,함수 래퍼,모듈 래핑,module wrapping', 'Node.js는 CommonJS 파일의 내용을 `(function (exports, require, module, __filename, __dirname) { ... })` 형태의 함수로 감싼 뒤, `this`를 `module.exports`로 지정해 호출한다. 그래서 인자 5개가 들어온 `arguments.length`가 5로 찍히고, 최상단 `this`가 `module.exports`와 같으며, 최상단 `var`는 이 함수의 지역 변수라 `globalThis`에 붙지 않는다. 최상단 `return`도 함수 본문 안의 return이므로 문법 오류가 아니다. `require`와 `__dirname`을 따로 가져오지 않고 쓸 수 있는 것도 이 매개변수 덕분이다. 한 번 불러온 모듈을 같은 객체로 돌려주는 모듈 캐시(`require.cache`)와는 다른 장치이며, ESM 파일은 이렇게 감싸지지 않아 최상단 `this`가 `undefined`이고 최상단 `return`은 SyntaxError가 난다.'),
       (1437, 4444, '엄격 모드,엄격모드,strict mode,strict 모드,스트릭트 모드,스트릭트모드,use strict,strict,엄격한 모드', 'ESM 파일은 `"use strict"`를 적지 않아도 항상 엄격 모드로 실행된다. 엄격 모드에서는 앞자리 0으로 시작하는 옛 8진수 리터럴(`0644`)이 문법 오류라 파일이 평가되기 전 파싱 단계에서 막히며, `0o644`처럼 접두어를 붙여야 한다. 또 함수를 객체 없이 그냥 호출하면 `this`가 전역 객체로 바뀌지 않고 `undefined`로 남아 `whoAmI() === globalThis`가 `false`가 된다. `type` 필드가 없는 프로젝트의 `.js` 파일은 CommonJS로 해석되고, `"use strict"`를 적지 않는 한 느슨한 모드(sloppy mode)라 두 코드가 그대로 동작했다. 최상단 변수가 전역이 되지 않는 모듈 스코프는 CommonJS에도 있는 성질이라, 8진수 리터럴 오류나 함수 호출의 `this` 차이를 설명하지 못한다는 점에서 엄격 모드와 구분된다.');

-- =====================================================
-- Lesson 868: 순환 참조와 라이브 바인딩, 지연 로딩
-- =====================================================

INSERT INTO problem (id, lesson_id, instruction, content, problem_type)
VALUES (5387, 868, '아래 main.js를 실행했을 때 콘솔에 출력되는 두 줄을 순서대로 나타낸 것은?', 'package.json에 `type` 필드가 없는 프로젝트에서 `node main.js`로 실행했다.

```javascript
// a.js
exports.ready = false;
const b = require(''./b'');
console.log(''a:'', b.ready);
exports.ready = true;
```

```javascript
// b.js
exports.ready = false;
const a = require(''./a'');
console.log(''b:'', a.ready);
exports.ready = true;
```

```javascript
// main.js
require(''./a'');
```', 'OBJECTIVE'),
       (5388, 868, '아래 main.mjs를 `node main.mjs`로 실행했을 때 콘솔에 출력되는 순서는?', '```javascript
// shared.mjs
console.log(''shared'');
```

```javascript
// a.mjs
import ''./shared.mjs'';
console.log(''a'');
```

```javascript
// b.mjs
import ''./shared.mjs'';
console.log(''b'');
```

```javascript
// main.mjs
console.log(''main'');
import ''./a.mjs'';
import ''./b.mjs'';
```', 'OBJECTIVE'),
       (5389, 868, '아래 app.mjs를 실행했을 때 콘솔에 출력되는 결과는?', '```javascript
// create-pool.cjs
function createPool(size) {
  return { size };
}
module.exports = createPool;
```

```javascript
// app.mjs
import createPool from ''./create-pool.cjs'';
import * as ns from ''./create-pool.cjs'';
console.log(typeof createPool, typeof ns.default, typeof ns.createPool);
```', 'OBJECTIVE'),
       (5390, 868, '아래 모듈 불러오기 방식에 대한 설명으로 옳은 것은?', '이 방식은 파일 최상단에 두는 선언문이 아니라, 코드가 실행되는 도중 필요한 자리에서 함수처럼 호출하는 표현식이다. CommonJS 파일과 ESM 파일 어디에서나 별도 준비 없이 쓸 수 있고, 불러올 경로를 실행 중에 문자열로 조립해 넘길 수도 있다.', 'OBJECTIVE'),
       (5391, 868, '아래 코드 변경으로 콜드 스타트가 줄어든 까닭이 된 최적화 기법의 이름은?', '번들러 없이 배포하는 Node.js 서버리스 함수다. `pdf-renderer`는 폰트·이미지 처리 라이브러리를 함께 불러오는 무거운 모듈이고, 요청 100건 중 3건 정도만 `exportPdf`를 거친다. 코드에서 바꾼 것은 `require` 한 줄의 위치뿐이다.

```javascript
// handler.js (변경 후)
const { findReport, toJson } = require(''./report-store'');

exports.getReport = async (id) => toJson(await findReport(id));

exports.exportPdf = async (id) => {
  const renderer = require(''./pdf-renderer''); // 변경 전에는 파일 최상단에 있던 줄
  return renderer.render(await findReport(id));
};
```

| 측정 항목 | 변경 전 | 변경 후 |
|---|---|---|
| 콜드 스타트 | 820ms | 340ms |
| `getReport` 응답 | 45ms | 45ms |
| 인스턴스의 첫 `exportPdf` 응답 | 600ms | 1,070ms |
| 두 번째 이후 `exportPdf` 응답 | 600ms | 600ms |', 'SUBJECTIVE'),
       (5392, 868, '아래 두 실행 결과의 차이를 만든 ESM의 특성을 가리키는 용어는?', '같은 상태 모듈을 CommonJS와 ESM으로 각각 작성해 실행했다.

```javascript
// status.cjs
let state = ''idle'';
function start() { state = ''running''; }
module.exports = { state, start };

// app.cjs
const status = require(''./status.cjs'');
console.log(status.state);
status.start();
console.log(status.state);
```

```javascript
// status.mjs
export let state = ''idle'';
export function start() { state = ''running''; }

// app.mjs
import { state, start } from ''./status.mjs'';
console.log(state);
start();
console.log(state);
```

```
$ node app.cjs
idle
idle

$ node app.mjs
idle
running
```', 'SUBJECTIVE');

INSERT INTO option (id, problem_id, content, explanation, is_answer)
VALUES
-- 문제 5387
(14539, 5387, '`b: undefined` → `a: true`', '순환 참조에서 상대 모듈의 빈 객체를 받는다고 본 오개념. a.js는 require(''./b'')보다 앞에서 exports.ready = false를 실행했으므로, b.js가 받은 미완성 exports 객체에도 ready가 이미 false로 들어 있다.', false),
(14540, 5387, '`b: true` → `a: true`', 'require가 상대 모듈의 실행이 끝날 때까지 기다려 완성된 객체를 준다고 본 오개념. a.js는 아직 실행 도중이라 b.js는 그 시점까지 채워진 exports를 받고, a의 exports.ready = true는 b.js가 끝난 뒤에야 실행된다.', false),
(14541, 5387, '`b: false` → `a: true`', 'a.js 실행 도중 b.js가 require(''./a'')를 부르면 캐시에 올라 있던 a의 미완성 exports가 그대로 돌아와 ready는 false다. b.js는 끝까지 실행돼 ready를 true로 바꾼 뒤 a.js로 돌아가므로 a가 읽는 b.ready는 true다.', true),
(14542, 5387, '`b: false` → `a: false`', '양쪽 모두 미완성 객체를 받는다고 본 오개념. 미완성 객체를 받는 곳은 순환을 닫는 b.js의 require(''./a'')뿐이다. b.js는 끝까지 실행된 뒤 a.js로 돌아가므로 a가 읽는 b.ready는 이미 true다.', false),

-- 문제 5388
(14543, 5388, '`shared` → `a` → `b` → `main`', 'ESM은 실행 전에 파싱·링킹으로 의존 그래프를 확정하고, 의존 모듈의 평가를 모두 마친 뒤 가져오는 쪽을 평가한다. import 선언은 적힌 위치와 무관하게 먼저 처리되고 shared.mjs는 한 번만 평가된다.', true),
(14544, 5388, '`main` → `shared` → `a` → `b`', 'require처럼 코드가 적힌 순서대로 불러온다고 본 오개념. import 선언은 실행 중에 만나는 호출이 아니라 평가 전에 처리되는 정적 선언이라, main.mjs 첫 줄의 console.log보다 의존 모듈 평가가 먼저다.', false),
(14545, 5388, '`shared` → `a` → `shared` → `b` → `main`', '가져올 때마다 모듈 본문이 다시 실행된다고 본 오개념. 같은 경로의 모듈은 의존 그래프에서 한 인스턴스로 묶여 한 번만 평가되고, b.mjs는 이미 평가된 shared.mjs를 그대로 쓴다.', false),
(14546, 5388, '`main` → `a` → `shared` → `b`', '가져오는 쪽 본문이 먼저 실행되고 의존 모듈은 나중에 평가된다고 본 오개념. ESM은 의존 모듈부터 평가해 올라오므로 shared가 a보다 먼저 찍히고, 모든 의존성을 가진 main은 가장 마지막이다.', false),

-- 문제 5389
(14547, 5389, '`undefined undefined function`', 'CommonJS에는 export default 문이 없으니 기본 가져오기가 비고, 함수 이름이 명명 내보내기가 된다고 본 오개념. ESM에서 CommonJS 모듈을 가져오면 module.exports 전체가 default로 들어오며, 함수 이름은 내보내기 이름과 무관하다.', false),
(14548, 5389, '`function undefined undefined`', '네임스페이스 객체에는 명명 내보내기만 담긴다고 본 오개념. CommonJS 모듈의 네임스페이스 객체에는 module.exports가 default 속성으로 들어 있어, ns.default는 기본 가져오기로 받은 createPool과 같은 함수다.', false),
(14549, 5389, '`function function function`', '대입한 함수의 이름이 명명 내보내기로 잡힌다고 본 오개념. Node.js는 CommonJS 소스를 훑어 exports.이름 = 값 같은 패턴에서 이름을 찾는데, module.exports에 변수 하나를 대입한 줄에서는 어떤 이름도 드러나지 않는다.', false),
(14550, 5389, '`function function undefined`', 'ESM에서 CommonJS 모듈을 가져오면 module.exports 전체가 기본 내보내기(default)가 되므로 기본 가져오기와 ns.default는 같은 함수다. 소스에 exports.이름 = 값 꼴이 없어 createPool이라는 명명 내보내기는 생기지 않는다.', true),

-- 문제 5390
(14551, 5390, '호출한 줄에서 모듈 객체를 곧바로 돌려주므로 결과를 변수에 담아 바로 속성을 꺼낼 수 있다.', 'require처럼 결과를 동기로 받는다고 본 오개념. 이 표현식은 Promise를 돌려주므로 await나 then으로 이행 값을 받은 뒤에야 모듈 객체를 쓸 수 있다.', false),
(14552, 5390, '기본 내보내기를 쓰려면 결과로 받은 모듈 객체에서 default 속성을 직접 꺼내야 한다.', '결과는 모듈의 모든 내보내기를 담은 네임스페이스 객체라서, 정적 import의 기본 가져오기처럼 default가 알아서 풀리지 않는다. 그래서 const { default: chalk } = await import(...)처럼 직접 꺼내 쓴다.', true),
(14553, 5390, '같은 경로로 여러 번 호출하면 호출할 때마다 모듈 파일을 다시 읽고 본문을 다시 실행한다.', '호출마다 모듈을 새로 실행한다고 본 오개념. 처음 호출할 때 불러와 평가한 모듈은 캐시되어, 이후 같은 경로로 호출하면 이미 만들어진 모듈 인스턴스를 그대로 돌려받는다.', false),
(14554, 5390, '경로를 실행 중에 조립해도 번들러가 쓰이지 않는 내보내기를 미리 골라내 결과물에서 뺀다.', '정적 import와 똑같이 최적화된다고 본 오개념. 경로가 실행 중에 정해지면 번들러는 어떤 모듈의 어떤 내보내기가 쓰일지 미리 알 수 없어, 정적 분석에 기대는 트리 셰이킹 혜택이 사라진다.', false);

INSERT INTO answer (id, problem_id, content, explanation)
VALUES (1752, 5391, '지연 로딩,지연로딩,지연 로드,레이지 로딩,레이지로딩,lazy loading,lazy-loading,lazyloading,lazy load,게으른 로딩,늦은 로딩,온디맨드 로딩,on-demand loading,lazy require,지연 require', '모듈을 앱이 시작할 때가 아니라 실제로 처음 쓰이는 순간에 불러오는 전략이 지연 로딩이다. CommonJS의 require는 동기 호출이라 함수 안처럼 코드 어디서나 부를 수 있고, 무거운 pdf-renderer를 exportPdf 안으로 옮기자 인스턴스가 뜰 때 이 모듈을 읽지 않아 콜드 스타트가 820ms에서 340ms로 줄었다. 대신 그 비용이 인스턴스의 첫 PDF 요청으로 옮겨 가 1,070ms가 되고, 한 번 불러온 모듈은 require.cache에 남아 두 번째 요청부터는 차이가 없다. 요청 대부분이 PDF를 쓰지 않는 상황이라 이득이 크다. ESM 전용 모듈이라면 같은 전략을 동적 import()로 구현한다. 번들러가 빌드 단계에서 결과물을 여러 파일로 나눠 내려받는 시점을 늦추는 코드 스플리팅, 쓰이지 않는 내보내기를 결과물에서 지우는 트리 셰이킹과는 구분된다. 이 사례는 번들러 없이 런타임에 불러오는 시점만 미룬 것이다.'),
       (1753, 5392, '라이브 바인딩,라이브바인딩,live binding,live bindings,live-binding,livebinding,실시간 바인딩', 'ESM의 import는 내보낸 변수의 값을 복사해 오지 않고 그 변수 자체와의 연결(바인딩)을 받는다. 그래서 status.mjs 안에서 start()가 state를 바꾸면 app.mjs가 읽는 state에도 곧바로 running이 보인다. 이 연결은 링킹 단계에서 만들어지고 읽기 전용이라, 가져온 쪽에서 state에 대입하면 TypeError가 난다. 반면 CommonJS의 module.exports = { state, start }는 내보내는 순간의 값 idle을 객체 속성에 복사해 담으므로, start()가 모듈 안의 변수를 바꿔도 status.state는 그대로다(값 복사). 한 번 불러온 모듈을 같은 객체로 돌려주는 모듈 캐시와도 다른 성질이다. 캐시는 같은 객체를 공유하게 할 뿐, 이미 복사해 둔 값을 새로 고쳐 주지 않는다.');
